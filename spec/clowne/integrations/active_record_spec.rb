describe 'AR adapter', :cleanup, adapter: :active_record, transactional: :active_record do
  before(:all) do
    module AR
      class ImgCloner < Clowne::Cloner
        trait :with_preview_image do
          include_association :preview_image, params: :preview_image
        end

        trait :nullify_title do
          nullify :title
        end
      end

      class BasePostCloner < Clowne::Cloner
        finalize do |_source, record, params|
          record.contents = params[:post_contents] if params[:post_contents].present?
        end
      end

      class PostCloner < BasePostCloner
        include_association :image, clone_with: 'AR::ImgCloner',
                                    traits: %i[with_preview_image nullify_title],
                                    params: true
        include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + ' Super!'
          end
        end

        trait :copy do
          init_as do |source, target:, **|
            target.contents = source.contents
            target
          end
        end
      end

      class PreviewImageCloner < Clowne::Cloner
        finalize do |_source, record, suffix:|
          record.some_stuff = record.some_stuff + suffix
        end
      end
    end
  end

  after(:all) do
    %w[ImgCloner BasePostCloner PostCloner PreviewImageCloner].each do |cloner|
      AR.send(:remove_const, cloner)
    end
  end

  let!(:image) { create(:image, title: 'Manager') }
  let!(:preview_image) do
    create(:preview_image, some_stuff: 'This is preview about my life', image: image)
  end
  let!(:post) { create(:post, title: 'TeamCity', image: image) }
  let(:topic) { post.topic }

  let!(:tags) do
    %w[CI CD JVM].map { |value| create(:tag, value: value) }.tap do |items|
      post.tags = items
    end
  end

  it 'clone all stuff' do
    expect(AR::Topic.count).to eq(1)
    expect(AR::Post.count).to eq(1)
    expect(AR::Tag.count).to eq(3)
    expect(AR::Image.count).to eq(1)
    expect(AR::PreviewImage.count).to eq(1)

    cloned = AR::PostCloner.call(
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD],
      post_contents: 'THIS IS CLONE! (☉_☉)',
      preview_image: { suffix: ' - 2' }
    ).to_record

    cloned.save!

    expect(AR::Topic.count).to eq(1)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(5)
    expect(AR::Image.count).to eq(2)
    expect(AR::PreviewImage.count).to eq(2)

    # post
    expect(cloned).to be_a(AR::Post)
    expect(cloned.title).to eq('TeamCity Super!')
    expect(cloned.contents).to eq('THIS IS CLONE! (☉_☉)')

    # image
    image_clone = cloned.image
    expect(image_clone).to be_a(AR::Image)
    expect(image_clone.title).to be_nil
    expect(image_clone.preview_image).to be_a(AR::PreviewImage)

    # preview_image
    preview_image_clone = image_clone.preview_image
    expect(preview_image_clone.some_stuff).to eq('This is preview about my life - 2')

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end

  it 'works with existing post' do
    a_post = create(:post, title: 'Thing').tap do |p|
      p.tags << create(:tag, value: 'RUM')
    end

    expect(AR::Topic.count).to eq(2)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(4)
    expect(AR::Image.count).to eq(2)
    expect(AR::PreviewImage.count).to eq(1)

    cloned = AR::PostCloner.call(
      post,
      traits: :copy,
      target: a_post,
      preview_image: { suffix: ' - 3' }
    ).to_record
    cloned.save!

    expect(cloned).to be_eql(a_post)

    expect(AR::Topic.count).to eq(2)
    expect(AR::Post.count).to eq(2)
    expect(AR::Tag.count).to eq(7)
    expect(AR::Image.count).to eq(3)
    expect(AR::PreviewImage.count).to eq(2)

    # post
    expect(a_post.title).to eq('Thing')
    expect(a_post.contents).to eq(post.contents)

    # preview_image
    preview_image_clone = a_post.image.preview_image
    expect(preview_image_clone.some_stuff).to eq('This is preview about my life - 3')

    # tags
    tags_clone = a_post.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD JVM RUM])
  end

  it 'works with partial clone' do
    cloned = AR::PostCloner.partial_apply(
      { association: :tags },
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD]
    ).to_record

    cloned.save!
    cloned.reload

    # title
    expect(cloned.title).to eq post.title

    # image
    expect(cloned.image).to be_nil

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end
end

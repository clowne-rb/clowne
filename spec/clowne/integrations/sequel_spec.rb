describe "Sequel adapter", :cleanup, adapter: :sequel, transactional: :sequel do
  before(:all) do
    module Sequel
      class UserCloner < Clowne::Cloner
        finalize { |_, record| record.email = "test@test.com" }
      end

      class ImgCloner < Clowne::Cloner
        exclude_association :preview_image

        trait :with_preview_image do
          include_association :preview_image
        end

        trait :nullify_title do
          nullify :title
        end
      end

      class BasePostCloner < Clowne::Cloner
        finalize do |_source, record, **params|
          record.contents = params[:post_contents] if params[:post_contents].present?
        end
      end

      class PostCloner < BasePostCloner
        include_association :image, clone_with: "Sequel::ImgCloner",
                                    traits: %i[with_preview_image nullify_title]
        include_association :tags, ->(params) { where(value: params[:tags]) if params[:tags] }

        trait :mark_as_clone do
          finalize do |source, record|
            record.title = source.title + " Super!"
          end
        end

        trait :copy do
          init_as do |source, target:|
            target.contents = source.contents
            target
          end
        end
      end

      class PreviewImageCloner < Clowne::Cloner
        finalize do |_source, record|
          record.some_stuff = record.some_stuff + " - 2"
        end
      end
    end
  end

  after(:all) do
    %w[ImgCloner BasePostCloner PostCloner PreviewImageCloner].each do |cloner|
      Sequel.send(:remove_const, cloner)
    end
  end

  let!(:post) { create("sequel:post", title: "TeamCity") }
  let!(:image) { create("sequel:image", title: "Manager", post: post) }
  let!(:user) { create("sequel:user", email: "user@email.com") }
  let!(:preview_image) do
    create("sequel:preview_image", some_stuff: "This is preview_image about my life", image: image)
  end
  let(:topic) { post.topic }

  let!(:tags) do
    %w[CI CD JVM].map { |value| create("sequel:tag", value: value) }.tap do |items|
      items.each { |tag| post.add_tag(tag) }
    end
  end

  it "clone all stuff" do
    expect(Sequel::Topic.count).to eq(1)
    expect(Sequel::Post.count).to eq(1)
    expect(Sequel::Tag.count).to eq(3)
    expect(Sequel::Image.count).to eq(1)
    expect(Sequel::PreviewImage.count).to eq(1)

    cloned_wrapper = Sequel::PostCloner.call(
      post,
      traits: :mark_as_clone,
      tags: %w[CI CD],
      post_contents: "THIS IS CLONE! (☉_☉)"
    )
    cloned = cloned_wrapper.persist

    expect(Sequel::Topic.count).to eq(1)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(5)
    expect(Sequel::Image.count).to eq(2)
    expect(Sequel::PreviewImage.count).to eq(2)

    # post
    expect(cloned).to be_a(Sequel::Post)
    expect(cloned.title).to eq("TeamCity Super!")
    expect(cloned.contents).to eq("THIS IS CLONE! (☉_☉)")

    # image
    image_clone = cloned.image
    expect(image_clone).to be_a(Sequel::Image)
    expect(image_clone.title).to be_nil
    expect(image_clone.preview_image).to be_a(Sequel::PreviewImage)

    # preview_image
    preview_image_clone = image_clone.preview_image
    expect(preview_image_clone.some_stuff).to eq("This is preview_image about my life - 2")

    # tags
    tags_clone = cloned.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD])
  end

  it "works with existing post", :aggregate_failures do
    a_post = create("sequel:post", title: "Thing").tap do |p|
      p.add_tag create("sequel:tag", value: "ROM")
    end

    expect(Sequel::Topic.count).to eq(2)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(4)
    expect(Sequel::Image.count).to eq(1)
    expect(Sequel::PreviewImage.count).to eq(1)

    cloned_wrapper = Sequel::PostCloner.call(
      post,
      traits: :copy,
      target: a_post
    )

    cloned = cloned_wrapper.persist

    expect(cloned).to be_eql(a_post)

    expect(Sequel::Topic.count).to eq(2)
    expect(Sequel::Post.count).to eq(2)
    expect(Sequel::Tag.count).to eq(7)
    expect(Sequel::Image.count).to eq(2)
    expect(Sequel::PreviewImage.count).to eq(2)

    # post
    expect(a_post).to be_a(Sequel::Post)
    expect(a_post.title).to eq("Thing")
    expect(a_post.contents).to eq(post.contents)

    # preview_image
    preview_image_clone = a_post.image.preview_image
    expect(preview_image_clone.some_stuff).to eq("This is preview_image about my life - 2")

    # tags
    tags_clone = a_post.tags
    expect(tags_clone.map(&:value)).to match_array(%w[CI CD JVM ROM])
  end

  it "works with no association model" do
    expect(Sequel::User.count).to eq(2)
    Sequel::UserCloner.call(user).persist
    expect(Sequel::User.count).to eq(3)
  end
end

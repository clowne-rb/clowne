require 'clowne/adapters/active_record/dsl'

describe 'AR DSl', :cleandb do
  before(:all) do
    module AR_DSL
      class User < ActiveRecord::Base
        has_many :posts, class_name: 'AR_DSL::Post', foreign_key: :owner_id

        clowne_config do
          include_association :posts

          nullify :email
        end
      end

      class Admin < User
        clowne_config do
          include_association :posts, :with_topics
        end
      end

      class Post < ActiveRecord::Base
        has_one :image, class_name: 'AR_DSL::Image'
        belongs_to :owner, class_name: 'AR_DSL::User'

        clowne_config do
          include_association :image

          finalize do |source, record, params|
            record.title = params[:title] || "Clone of #{source.title}"
          end
        end

        scope :with_topics, -> { where.not(topic_id: nil) }
      end

      class DraftPost < Post
        clowne_config(inherit: false) {}
      end

      class Image < ActiveRecord::Base
        belongs_to :post, class_name: 'AR_DSL::Post'
      end
    end
  end

  after(:all) do
    %w[User Admin Post DraftPost Image].each do |klass|
      AR_DSL.send(:remove_const, klass)
    end
  end

  let!(:user) { AR_DSL::User.create!(name: 'Jack Sparrow', email: 'sparrow@black.pearl.test') }

  let!(:post) do
    AR_DSL::Post.create!(
      owner: user, topic_id: 123, title: 'Pirates of XXI century',
      contents: "Let's rock!"
    )
  end

  let!(:draft_post) do
    AR_DSL::DraftPost.create!(owner: user, topic_id: nil, title: '[wip]', contents: 'TBD')
  end

  let!(:image) { AR_DSL::Image.create!(post: post, title: 'Union Black') }
  let!(:draft_image) { AR_DSL::Image.create!(post: draft_post, title: 'Draf of Union Black') }

  describe '#clowne' do
    it 'uses in-model config' do
      cloned_post = post.clowne(title: 'New Post').clone

      expect(cloned_post.title).to eq 'New Post'
      expect(cloned_post.image).not_to be_nil
      expect(cloned_post.image.title).to eq 'Union Black'
    end

    it 'works with inherit: false' do
      cloned_post = draft_post.clowne(title: 'New Post').clone

      expect(cloned_post.title).to eq '[wip]'
      expect(cloned_post.image).to be_nil
    end

    it 'works with inheritance' do
      admin = AR_DSL::Admin.find(user.id)

      cloned_admin = admin.clowne.clone
      cloned_user = user.clowne.clone

      expect(cloned_user.email).to be_nil
      expect(cloned_user.posts.size).to eq 2

      expect(cloned_admin.email).to be_nil
      expect(cloned_admin.posts.size).to eq 1
      expect(cloned_admin.posts.first.title).to eq 'Clone of Pirates of XXI century'
    end

    it 'works with inline config' do
      cloned_post = draft_post.clowne(title: 'New Post') do
        nullify :owner_id
      end.clone

      expect(cloned_post.title).to eq '[wip]'
      expect(cloned_post.image).to be_nil
      expect(cloned_post.owner_id).to be_nil
    end
  end
end

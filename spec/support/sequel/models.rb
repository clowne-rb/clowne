Sequel::Model.plugin :timestamps, force: true, update_on_create: true

module Sequel
  class Topic < Sequel::Model
    one_to_many :posts
  end

  class User < Sequel::Model
    one_to_many :posts, key: :owner_id
  end

  class Post < Sequel::Model
    many_to_one :topic
    many_to_one :owner, class_name: Sequel::User
    one_to_one :account

    dataset_module do
      def about_animals
        filter(title: 'animals')
      end
    end
    # one_to_one :history, through: :account
    # has_and_belongs_to_many :tags
  end

  class Account < Sequel::Model
    many_to_one :post
    # has_one :history
  end
  #
  # class History < Sequel::Model
  #   belongs_to :account
  # end
  #
  # class Tag < Sequel::Model
  #   has_and_belongs_to_many :posts
  # end
end

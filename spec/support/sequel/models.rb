Sequel::Model.plugin :timestamps, force: true, update_on_create: true
Sequel::Model.plugin :nested_attributes

module Sequel
  class Topic < Sequel::Model
    one_to_many :posts
  end

  class User < Sequel::Model
    one_to_many :posts, key: :owner_id

    nested_attributes :posts
    # has_many :accounts, through: :posts - Does not supported in Sequel
  end

  class Post < Sequel::Model
    many_to_one :topic
    many_to_one :owner, class_name: Sequel::User
    one_to_one :account
    # has_one :history, through: :account - Does not supported in Sequel
    many_to_many :tags

    nested_attributes :account
    nested_attributes :tags

    dataset_module do
      def alpha_first
        order(::Sequel.asc(:title)).limit(1)
      end
    end
  end

  class Account < Sequel::Model
    many_to_one :post
    one_to_one :history

    nested_attributes :history
  end

  class History < Sequel::Model
    many_to_one :account
  end

  class Tag < Sequel::Model
    many_to_many :posts
  end
end

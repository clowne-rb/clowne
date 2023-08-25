# frozen_string_literal: true

Sequel::Model.plugin :timestamps, force: true, update_on_create: true
Sequel::Model.plugin :nested_attributes

module Sequel
  class Topic < Sequel::Model
    one_to_many :posts
    many_to_one :image

    nested_attributes :posts
  end

  class User < Sequel::Model
    one_to_many :posts, key: :owner_id

    nested_attributes :posts
    # has_many :accounts, through: :posts - Does not supported in Sequel
  end

  class Post < Sequel::Model
    many_to_one :topic
    many_to_one :owner, class_name: Sequel::User
    one_to_one :image
    # has_one :prevew_image, through: :image - Does not supported in Sequel
    many_to_many :tags

    nested_attributes :image
    nested_attributes :tags
    nested_attributes :topic # For testing Noop resolver

    dataset_module do
      def alpha_first
        order(::Sequel.asc(:title)).limit(1)
      end
    end
  end

  class Image < Sequel::Model
    many_to_one :post
    one_to_one :preview_image

    nested_attributes :preview_image
  end

  class PreviewImage < Sequel::Model
    many_to_one :image
  end

  class Tag < Sequel::Model
    many_to_many :posts
  end
end

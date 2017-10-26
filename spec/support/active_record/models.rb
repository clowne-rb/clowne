class Topic < ActiveRecord::Base
  has_many :posts
end

class User < ActiveRecord::Base
  has_many :posts, foreign_key: :owner_id
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :owner, class_name: 'User'
  has_one :account
  has_one :history, through: :account
  has_and_belongs_to_many :tags
end

class Account < ActiveRecord::Base
  belongs_to :post
  has_one :history
end

class History < ActiveRecord::Base
  belongs_to :account
end

class Tag < ActiveRecord::Base
  has_and_belongs_to_many :posts
end

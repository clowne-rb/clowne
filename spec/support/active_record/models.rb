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
end

class Account < ActiveRecord::Base
  belongs_to :post
  has_one :history
end

class History < ActiveRecord::Base
  belongs_to :account
end

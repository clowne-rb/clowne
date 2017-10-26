class Topic < ActiveRecord::Base
  has_many :posts
end

class User < ActiveRecord::Base
  has_many :posts
end

class Post < ActiveRecord::Base
  belongs_to :topic
  belongs_to :owner, class_name: 'User'
end

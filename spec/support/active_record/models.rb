module AR
  class Topic < ActiveRecord::Base
    has_many :posts, class_name: 'AR::Post'
  end

  class User < ActiveRecord::Base
    has_many :posts, class_name: 'AR::Post', foreign_key: :owner_id
    has_many :accounts, class_name: 'AR::Account', through: :posts
  end

  class Post < ActiveRecord::Base
    belongs_to :topic, class_name: 'AR::Topic'
    belongs_to :owner, class_name: 'AR::User'
    has_one :account, class_name: 'AR::Account'
    has_one :history, through: :account, class_name: 'AR::History'
    has_and_belongs_to_many :tags, class_name: 'AR::Tag'

    scope :alpha_first, -> { order(title: :asc).limit(1) }
  end

  class Account < ActiveRecord::Base
    belongs_to :post, class_name: 'AR::Post'
    has_one :history, class_name: 'AR::History'
  end

  class History < ActiveRecord::Base
    belongs_to :account, class_name: 'AR::Account'
  end

  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :posts, class_name: 'AR::Post'
  end
end

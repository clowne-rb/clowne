module AR
  class Topic < ActiveRecord::Base
    has_many :posts, class_name: 'AR::Post'
  end

  class User < ActiveRecord::Base
    has_many :posts, class_name: 'AR::Post', foreign_key: :owner_id
    has_many :images, class_name: 'AR::Image', through: :posts
  end

  class Post < ActiveRecord::Base
    belongs_to :topic, class_name: 'AR::Topic'
    belongs_to :owner, class_name: 'AR::User'

    has_one :image, class_name: 'AR::Image'
    has_one :preview_image, through: :image, class_name: 'AR::PreviewImage'

    has_and_belongs_to_many :tags, class_name: 'AR::Tag'

    scope :alpha_first, -> { order(title: :asc).limit(1) }
  end

  class Image < ActiveRecord::Base
    belongs_to :post, class_name: 'AR::Post'
    belongs_to :topic, class_name: 'AR:Topic'

    has_one :preview_image, class_name: 'AR::PreviewImage'
  end

  class PreviewImage < ActiveRecord::Base
    belongs_to :image, class_name: 'AR::Image'
  end

  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :posts, class_name: 'AR::Post'
  end
end

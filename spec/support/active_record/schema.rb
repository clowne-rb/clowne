ActiveRecord::Schema.define do
  self.verbose = false

  create_table :schema_migrations, force: true

  create_table :topics, force: true do |t|
    t.string :title
    t.string :description
    t.integer :image_id
    t.timestamps null: true
  end

  create_table :users, force: true do |t|
    t.string :name
    t.string :email
    t.timestamps null: true
  end

  create_table :posts, force: true do |t|
    t.integer :owner_id
    t.integer :topic_id
    t.string :title
    t.string :contents
    t.timestamps null: true
  end

  create_table :tags, force: true do |t|
    t.string :value
    t.timestamps null: true
  end

  create_table :posts_tags, force: true do |t|
    t.integer :post_id
    t.integer :tag_id
  end

  create_table :images, force: true do |t|
    t.integer :post_id
    t.string :title
    t.timestamps null: true
  end

  create_table :preview_images, force: true do |t|
    t.integer :image_id
    t.string :some_stuff
    t.timestamps null: true
  end
end

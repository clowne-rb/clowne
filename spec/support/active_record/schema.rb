ActiveRecord::Schema.define do
  self.verbose = false

  create_table :topics, force: true do |t|
    t.string :title
    t.string :description
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

  create_table :accounts, force: true do |t|
    t.integer :post_id
    t.string :title
    t.timestamps null: true
  end

  create_table :histories, force: true do |t|
    t.integer :account_id
    t.string :some_stuff
    t.timestamps null: true
  end
end

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
end

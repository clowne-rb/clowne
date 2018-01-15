SEQUEL_DB.create_table :topics do
  primary_key :id
  String :title
  String :description
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :users do
  primary_key :id
  String :name
  String :email
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :posts do
  primary_key :id
  Integer :owner_id
  Integer :topic_id
  String :title
  String :contents
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :tags do
  primary_key :id
  String :value
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :posts_tags do
  primary_key :id
  Integer :post_id
  Integer :tag_id
end

SEQUEL_DB.create_table :accounts do
  primary_key :id
  Integer :post_id
  String :title
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :histories do
  primary_key :id
  Integer :account_id
  String :some_stuff
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

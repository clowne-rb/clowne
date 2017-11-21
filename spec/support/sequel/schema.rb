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

SEQUEL_DB.create_table :accounts do
  primary_key :id
  Integer :post_id
  String :title
end

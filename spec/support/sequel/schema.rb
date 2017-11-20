SEQUEL_DB.create_table :cars do
  primary_key :id
  String :title
  String :description
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :racers do
  primary_key :id
  String :name
  String :email
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

SEQUEL_DB.create_table :tracks do
  Integer :owner_id
  Integer :country_id
  String :name
  String :location
  DateTime :created_at, null: false
  DateTime :updated_at, null: false
end

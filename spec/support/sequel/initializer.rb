require 'sequel'
db =
  if RUBY_PLATFORM =~ /java/
    'jdbc:sqlite::memory:'
  else
    'sqlite::memory:'
  end

SEQUEL_DB = Sequel.connect(db)

require_relative './schema.rb'
require_relative './models.rb'

require 'sequel'

SEQUEL_DB = Sequel.sqlite

require_relative './schema.rb'
require_relative './models.rb'

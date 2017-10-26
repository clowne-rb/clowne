require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

load File.dirname(__FILE__) + '/schema.rb'
load File.dirname(__FILE__) + '/models.rb'

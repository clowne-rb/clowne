require 'activerecord-jdbc-adapter' if defined? JRUBY_VERSION
require 'activerecord-jdbcsqlite3-adapter' if defined? JRUBY_VERSION

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

load File.dirname(__FILE__) + '/schema.rb'
load File.dirname(__FILE__) + '/models.rb'

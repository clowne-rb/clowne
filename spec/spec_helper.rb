require 'active_record'
require 'clowne'
require 'factory_bot'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

if ENV['CC_REPORT']
  require 'simplecov'
  SimpleCov.start
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Clowne.default_adapter = FakeAdapter

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods
  config.include ClowneHelpers

  config.after(:each, cleanup: true) do
    ActiveRecord::Base.subclasses.each(&:delete_all)
    Clowne::Cloner.descendants.each do |cloner|
      Object.send(:remove_const, cloner.name) if cloner.name
      Clowne::Cloner.descendants.delete(cloner)
    end
  end
end

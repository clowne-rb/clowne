require 'active_record'
require 'clowne'

begin
  require 'pry-byebug'
rescue LoadError # rubocop:disable Lint/HandleExceptions
end

if ENV['CC_REPORT']
  require 'simplecov'
  SimpleCov.start
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:each) do
    Clowne::Cloner.descendants.each do |cloner|
      if cloner.name
        Object.send(:remove_const, cloner.name)
        Clowne::Cloner.descendants.delete(cloner)
      end
    end
  end
end

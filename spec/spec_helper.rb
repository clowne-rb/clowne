require 'active_record'
require 'sequel'
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
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.order = :random

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include FactoryBot::Syntax::Methods
  config.include_context 'adapter:active_record', adapter: :active_record
  config.include_context 'adapter:sequel', adapter: :sequel

  config.before(:each, cleanup: true) do
    cleanup(ActiveRecord::Base, &:delete_all)

    cleanup(Sequel::Model) do |sequel_class|
      sequel_class.dataset.delete
    end
  end

  def cleanup(base_class)
    base_class.subclasses.each do |orm_class|
      yield(orm_class)
      orm_class.remove_instance_variable(:@_clowne_cloner) if
        orm_class.instance_variable_defined?(:@_clowne_cloner)
    end
  end
end

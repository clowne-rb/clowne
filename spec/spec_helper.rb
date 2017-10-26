require 'clowne'
require 'pry'

require_relative 'support/active_record/initializer.rb'

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in clowne.gemspec
gemspec

gem "debug", platform: :mri

gem "sqlite3", "~> 1.4.2", platform: :ruby
gem "activerecord-jdbcsqlite3-adapter", ">= 60.0", "< 70.0", platform: :jruby
gem "jdbc-sqlite3", platform: :jruby

gem "activerecord", ">= 6.0"
gem "sequel", ">= 5.0"
gem "simplecov"

eval_gemfile "gemfiles/rubocop.gemfile"

local_gemfile = "Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end

# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in clowne.gemspec
gemspec

gem "debug", platform: :mri

gem "sqlite3", "~> 2.0", platform: :ruby
gem "activerecord-jdbcsqlite3-adapter", platform: :jruby
gem "jdbc-sqlite3", platform: :jruby

gem "activerecord", ">= 7.0"
gem "sequel", ">= 5.0"
gem "simplecov"

eval_gemfile "gemfiles/rubocop.gemfile"

local_gemfile = "Gemfile.local"

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end

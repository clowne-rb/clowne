source 'https://rubygems.org'

# Specify your gem's dependencies in clowne.gemspec
gemspec

gem 'pry-byebug'
gem 'sqlite3'
gem 'activerecord', '>= 5.0'

local_gemfile = 'Gemfile.local'

if File.exist?(local_gemfile)
  eval(File.read(local_gemfile)) # rubocop:disable Security/Eval
end

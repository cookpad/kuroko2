source 'https://rubygems.org'

# Declare your gem's dependencies in kuroko2.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

# Workaround for https://github.com/rails/rails/pull/54264
gem 'concurrent-ruby', '< 1.3.5'

group :test do
  gem 'pry-byebug'
  gem 'timecop'
  gem 'webmock'
  gem 'database_rewinder'
  gem 'rails-controller-testing'
end

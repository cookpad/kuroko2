$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kuroko2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kuroko2"
  s.version     = Kuroko2::VERSION
  s.authors     = ["Naoto Takai", "Eisuke Oishi"]
  s.email       = ["eisuke-oishi@cookpad.com"]
  s.homepage    = "https://github.com/cookpad/kuroko2"
  s.summary     = "Kuroko2 is a web-based job scheduler/workflow manager."
  s.description = "Kuroko2 is a web-based job scheduler/workflow manager created at Cookpad Inc."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", "bin/*.rb"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 5.0.0.1"
  s.add_dependency "kaminari"
  s.add_dependency "chrono"
  s.add_dependency "hashie"
  s.add_dependency "addressable"
  s.add_dependency 'aws-sdk', '~> 2'
  s.add_dependency 'retryable'
  s.add_dependency 'faraday'
  s.add_dependency 'sprockets'
  s.add_dependency 'slim-rails'
  s.add_dependency 'sass', '~> 3.4.5'
  s.add_dependency 'sass-rails'
  s.add_dependency 'uglifier', '~> 2.7.1'
  s.add_dependency 'jbuilder'
  s.add_dependency 'coffee-script', '~> 2.3.0'

  s.add_dependency 'jquery-rails'
  s.add_dependency 'momentjs-rails'
  s.add_dependency 'rails_bootstrap_sortable'
  s.add_dependency "select2-rails"
  s.add_dependency 'rack-store', '~> 0.0.4'
  s.add_dependency 'dotenv-rails', '~> 0.11.1'
  s.add_dependency 'serverengine', '~> 1.5.7'
  s.add_dependency 'omniauth-google-oauth2', '~> 0.2.4'

  s.add_dependency 'html-pipeline'
  s.add_dependency 'commonmarker', '~> 0.16.0'
  s.add_dependency 'font-awesome-rails'
  s.add_dependency 'rinku'
  s.add_dependency 'visjs-rails'

  s.add_dependency 'hipchat', '~> 1.3.0'
  s.add_dependency 'dalli', '~> 2.7.2'

  s.add_dependency 'the_garage'
  s.add_dependency 'weak_parameters'

  s.add_development_dependency 'mysql2', '< 0.5'
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'poltergeist'
end

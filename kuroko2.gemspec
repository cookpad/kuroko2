$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kuroko2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kuroko2"
  s.version     = Kuroko2::VERSION
  s.authors     = ["Eisuke Oishi"]
  s.email       = ["eisuke-oishi@cookpad.com"]
  s.homepage    = "https://github.com/cookpad/kuroko2"
  s.summary     = "Kuroko2 is a web-based job scheduler/workflow manager."
  s.description = "Kuroko2 is a web-based job scheduler/workflow manager created at Cookpad inc."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 4.2.7.1"
  s.add_development_dependency "mysql2"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_girl_rails"
  s.add_dependency "kaminari"
  s.add_dependency "chrono"
  s.add_dependency "hashie"
end

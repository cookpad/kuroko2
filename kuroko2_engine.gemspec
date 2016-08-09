$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kuroko2_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kuroko2_engine"
  s.version     = Kuroko2Engine::VERSION
  s.authors     = ["Eisuke Oishi"]
  s.email       = ["eisuke-oishi@cookpad.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Kuroko2Engine."
  s.description = "TODO: Description of Kuroko2Engine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.7"

  s.add_development_dependency "sqlite3"
end

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "kuroko2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "kuroko2"
  s.version     = Kuroko2::VERSION
  s.authors     = ["Eisuke Oishi"]
  s.email       = ["eisuke-oishi@cookpad.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Kuroko2."
  s.description = "TODO: Description of Kuroko2."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"

  s.add_development_dependency "sqlite3"
end

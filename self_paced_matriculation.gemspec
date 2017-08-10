$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "self_paced_matriculation/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "self_paced_matriculation"
  s.version     = SelfPacedMatriculation::VERSION
  s.authors     = ["James Carbine"]
  s.email       = ["jamescarbine@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of SelfPacedMatriculation."
  s.description = "TODO: Description of SelfPacedMatriculation."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
end

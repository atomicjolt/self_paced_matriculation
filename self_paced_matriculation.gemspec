$:.push File.expand_path("../lib", __FILE__)

require "self_paced_matriculation/version"

Gem::Specification.new do |s|
  s.name        = "self_paced_matriculation"
  s.version     = SelfPacedMatriculation::VERSION
  s.authors     = ["Atomic Jolt", "Scott Phillips"]
  s.email       = ["scott.phillips@atomicjolt.com"]
  s.homepage    = "https://github.com/atomicjolt/self_paced_matriculation"
  s.summary     = "Enables Self-Paced Enrollments through the Canvas API"
  s.license     = "AGPL-3.0"
  s.extra_rdoc_files = ["README.md"]

  s.required_ruby_version = ">= 2.3"

  s.files = Dir["{db,lib}/**/*"]

  s.add_dependency "rails", ">= 5.0"
end

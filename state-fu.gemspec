# -*- encoding: utf-8 -*-
require File.join( File.dirname( __FILE__ ), 'lib', 'state_fu', 'version' )

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.name              = "state-fu"
  s.version           = StateFu::VERSION
  s.platform          = Gem::Platform::RUBY
  s.authors           = ["David Lee"]
  s.date              = "2009-04-24"
  s.description       = "StateFu is a library for state-oriented programming in Ruby and/or Rails."
  s.email             = "david@rubyist.net.au"
  s.files             = %w/ LICENSE README.textile / + Dir.glob("{lib,spec}/**/*")
  s.has_rdoc          = true
  s.homepage          = "http://github.com/davidlee/state-fu"
  s.rdoc_options      = ["--inline-source", "--charset=UTF-8"]
  s.require_paths     = ["lib"]
  s.rubyforge_project = s.name
  s.rubygems_version  = StateFu::VERSION
  s.summary           = s.description

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mime-types>, [">= 1.15"])
      s.add_runtime_dependency(%q<diff-lcs>, [">= 1.1.2"])
    else
      s.add_dependency(%q<mime-types>, [">= 1.15"])
      s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
    end
  else
    s.add_dependency(%q<mime-types>, [">= 1.15"])
    s.add_dependency(%q<diff-lcs>, [">= 1.1.2"])
  end
end

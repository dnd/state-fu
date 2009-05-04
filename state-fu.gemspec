# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{state-fu}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David Lee"]
  s.date = %q{2009-05-04}
  s.description = %q{A rich library for state-oriented programming with state machines / workflows}
  s.email = %q{david@rubyist.net.au}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.textile"
  ]
  s.files = [
    "Rakefile",
    "lib/no_stdout.rb",
    "lib/state-fu.rb",
    "lib/state_fu/binding.rb",
    "lib/state_fu/core_ext.rb",
    "lib/state_fu/event.rb",
    "lib/state_fu/exceptions.rb",
    "lib/state_fu/fu_space.rb",
    "lib/state_fu/helper.rb",
    "lib/state_fu/hooks.rb",
    "lib/state_fu/interface.rb",
    "lib/state_fu/lathe.rb",
    "lib/state_fu/logger.rb",
    "lib/state_fu/machine.rb",
    "lib/state_fu/method_factory.rb",
    "lib/state_fu/persistence.rb",
    "lib/state_fu/persistence/active_record.rb",
    "lib/state_fu/persistence/attribute.rb",
    "lib/state_fu/persistence/base.rb",
    "lib/state_fu/persistence/session.rb",
    "lib/state_fu/sprocket.rb",
    "lib/state_fu/state.rb",
    "lib/state_fu/transition.rb",
    "spec/helper.rb",
    "spec/integration/active_record_persistence_spec.rb",
    "spec/integration/class_accessor_spec.rb",
    "spec/integration/event_definition_spec.rb",
    "spec/integration/ex_machine_for_accounts_spec.rb",
    "spec/integration/example_01_document_spec.rb",
    "spec/integration/example_02_string_spec.rb",
    "spec/integration/instance_accessor_spec.rb",
    "spec/integration/machine_duplication_spec.rb",
    "spec/integration/requirement_reflection_spec.rb",
    "spec/integration/sanity_spec.rb",
    "spec/integration/state_definition_spec.rb",
    "spec/integration/transition_spec.rb",
    "spec/spec.opts",
    "spec/units/binding_spec.rb",
    "spec/units/event_spec.rb",
    "spec/units/exceptions_spec.rb",
    "spec/units/fu_space_spec.rb",
    "spec/units/lathe_spec.rb",
    "spec/units/machine_spec.rb",
    "spec/units/method_factory_spec.rb",
    "spec/units/sprocket_spec.rb",
    "spec/units/state_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/davidlee/state-fu}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{state-fu}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A rich library for state-oriented programming with state machines / workflows}
  s.test_files = [
    "spec/units/machine_spec.rb",
    "spec/units/sprocket_spec.rb",
    "spec/units/event_spec.rb",
    "spec/units/lathe_spec.rb",
    "spec/units/binding_spec.rb",
    "spec/units/state_spec.rb",
    "spec/units/method_factory_spec.rb",
    "spec/units/exceptions_spec.rb",
    "spec/units/fu_space_spec.rb",
    "spec/helper.rb",
    "spec/integration/example_01_document_spec.rb",
    "spec/integration/transition_spec.rb",
    "spec/integration/class_accessor_spec.rb",
    "spec/integration/instance_accessor_spec.rb",
    "spec/integration/requirement_reflection_spec.rb",
    "spec/integration/machine_duplication_spec.rb",
    "spec/integration/state_definition_spec.rb",
    "spec/integration/event_definition_spec.rb",
    "spec/integration/sanity_spec.rb",
    "spec/integration/active_record_persistence_spec.rb",
    "spec/integration/example_02_string_spec.rb",
    "spec/integration/ex_machine_for_accounts_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

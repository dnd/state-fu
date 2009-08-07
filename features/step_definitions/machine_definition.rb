Then /^the ([a-z_]+) should have the name :([a-z_]+)$/ do |type, name|
  instance_variable_get("@#{type}").name.should == name.to_sym
end

Then /^the ([a-z_]+) should have an option :([a-z_]+) with the value (.+)$/ do |type, key, val|
  instance_variable_get("@#{type}").options[key.to_sym].should == eval(val)
end

Then /^the state should have an option "([^\"]*)" with the value false$/ do |arg1|
  @state.options[arg1].should == false
end

Then /^the machine should have a StateFu::(\w+) called :([a-z_]+)$/ do |type, name|
  @machine.send(type.downcase + 's').map(&:name).should include(name.to_sym)
end

Then /^I can retrieve a ([a-zA-Z:]+) by calling ([a-z_]+)\[:([a-z_]+)\] on the machine$/ do |klass, meth, state_name|
  value = @machine.send(meth)[state_name.to_sym]
  value.should be_kind_of(klass.constantize)
  store_object( value )
end

Then /^the event's ([a-z_]+) should be nil$/ do |meth|
  @event.send(meth).should be_nil
end

Then /^the event's ([a-z_]+) should include the StateFu::State called :([a-z_]+)$/ do |meth, state_name|
  @event.send(meth).should include(@machine.states[state_name.to_sym])
end

Then /^the machine should have an initial_state called :([a-z_]+)$/ do |state_name|
  @machine.initial_state.name.should == state_name.to_sym
end

Then /^the machine should have a list of states with four StateFu::States$/ do
  @list = @machine.states
  @list.length.should == 4
end

Then /^the StateFu::State called :before should be last in the list$/ do
  @list.map(&:name).last.should == :before
end

Then /^MyClass\.machines should be of size 2$/ do
  MyClass.machines.size.should == 2
end

Then /^MyClass\.machines\[:([a-z_]+)\] should return a StateFu::Machine$/ do |name|
  @machine = MyClass.machines[name.to_sym]
  @machine.should be_kind_of( StateFu::Machine )
end

Then /^the machine should not have any StateFu::Event$/ do
  @machine.events.should be_empty
end

Then /^the two StateFu::States called :zombie should be different objects$/ do
  thread = MyClass.machine(:thread_status)
  undead = MyClass.machine(:undead_status)
  thread.should_not == undead
  thread.object_id.should_not == undead.object_id
end

Then /^the machine should not have a StateFu::State called :vampire$/ do
  @machine.states[:vampire].should be_nil
end

Then /^the event should (not )?be simple\?$/ do |negative|
  if negative
    @event.should_not be_simple
  else
    @event.should be_simple
  end
end

Then /^the event :([a-z_]+) +should transition from (.*) to (.*)$/ do |e, from, to|
  e = @machine.events[e.to_sym]
  e.should be_kind_of( StateFu::Event )
  rx = /[:\[\], ]/
  from = from.split(rx).reject(&:empty?).map(&:to_sym)
  to   = to.split(rx).reject(&:empty?).map(&:to_sym)
  from.each { |origin| e.origins.map(&:name).should include(origin) }
  to  .each { |target| e.targets.map(&:name).should include(target) }
end

Given /^I have defined this machine$/ do |string|
  @machine = eval string
end

When /^I call (.*)$/ do |code|
  @result = eval code
end

Then /^([^ ]+) (?:should equal|equals) (.*)$/ do |code, expect|
  eval(code).should == eval(expect)
end

Then /^I should not have to pay my ex\-wife anything$/ do
  # it would have thrown a NoMethodError if it was called
end

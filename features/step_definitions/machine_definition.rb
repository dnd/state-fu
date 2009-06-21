Then /^the ([a-z_]+) should have the name :([a-z_]+)$/ do |type, name|
  instance_variable_get("@#{type}").name.should == name.to_sym
end

Then /^the ([a-z_]+) should have an option :([a-z_]+) with the value (.+)$/ do |type, key, val|
  instance_variable_get("@#{type}").options[key.to_sym].should == eval(val)
end

Then /^the machine should have a StateFu::(\w+) called :([a-z_]+)$/ do |type, name|
  @machine.send(type.downcase + 's').map(&:name).should include(name.to_sym)
end

Then /^I can retrieve a ([a-zA-Z:]+) by calling ([a-z_]+)\[:([a-z_]+)\] on the machine$/ do |klass, meth, state_name|
  ivar = '@' + klass.split('::').last.downcase
  value = @machine.send(meth)[state_name.to_sym]
  value.should be_kind_of(klass.constantize)
  instance_variable_set( ivar, value )
end

Then /^the event's ([a-z_]+) should be nil$/ do |meth|
  @event.send(meth).should be_nil
end

Then /^the event's ([a-z_]+) should include the StateFu::State called :([a-z_]+)$/ do |meth, state_name|
  @event.send(meth).should include(@machine.states[state_name.to_sym])
end

Then /^MyClass should have the class method '(\w+)'$/ do |meth|
  MyClass.should respond_to( meth )
end

Then /^(\w+) should respond to '(\w+)'$/ do |klass, meth|
  Object.const_get(klass).should respond_to(meth)
end

Then /^it should return the same StateFu::Machine on subsequent invocations of MyClass.machine$/ do
  MyClass.machine.should == @result
  MyClass.machine.object_id.should == @result.object_id
end

Then /^it should be bound to (\w+) with the name :([a-z_]+)$/ do |klass, name|
  klass = klass.constantize
  klass.machine.should be_kind_of( StateFu::Machine )
  klass.machine.should == StateFu::FuSpace.class_machines[klass][name.to_sym]
end

Given /^I have defined the default machine for MyClass$/ do
  MyClass.machine()
end

Then /^I should get a hash of StateFu::Machines and their names$/ do
  @result.should be_kind_of(Hash)
  @result.keys.map(&:class).uniq.should == [Symbol]
  @result.values.map(&:class).uniq.should == [StateFu::Machine]
end

Then /^it should contain one Machine with the default name :state_fu$/ do
  @result.size.should == 1
  @result.keys.should == [:state_fu]
  @result[:state_fu].should be_kind_of( StateFu::Machine )
end

Then /^I should get a list of machine names for MyClass$/ do
  @result.should respond_to(:each)
  @result.length.should == MyClass.machines.length
end

Then /^it should contain only the default name :state_fu$/ do
  @result.should == [:state_fu]
end

When /^I create an instance of (\w+) called (@\w+)$/ do |klass, ivar|
  instance_variable_set(ivar, Object.const_get(klass).new )
end

Then /^(@\w+) should respond to '([a-z_!\?]+)'$/ do |ivar, meth|
  instance_variable_get(ivar).should respond_to(meth)
end

#When /^I call (@\w+)\.([a-z_!?]+)( to .*)?$/ do |ivar, meth, reason|
#  @result = instance_variable_get(ivar).send(meth)
#end

Then /^I should receive an? ([a-zA-Z:]+)$/ do |const|
  constant = const.constantize
  @result.should be_kind_of(constant)
  ivar = '@' + @result.class.to_s.split('::').last.downcase
  instance_variable_set(ivar, @result)
end

Then /^it should refer to the default StateFu::Machine for MyClass$/ do
  @result.machine.should == MyClass.machine
end

Then /^I should receive the same StateFu::Binding on successive invocations$/ do
  @result2 = @my_obj.state_fu
  @result2.object_id.should == @result.object_id
end

Then /^it should have one element$/ do
  @result.size.should == 1
end

Then /^it should include the default machine name :(\w+) in its keys$/ do |key|
  @result.keys.should include(key.to_sym)
end

Then /^it should have a binding to the default StateFu::Machine for the class in its values$/ do
  @result[:state_fu].machine.should == MyClass.machine
end

Given /^I have not called @my_obj\.state_fu$/ do
  true
end

Then /^it should be empty$/ do
  @result.should be_empty
end

Then /^it should contain a binding to the default StateFu::Machine for the class$/ do
  @result.map(&:machine).should include( MyClass.machine )
end

Then /^@my_obj\.bindings should not be empty$/ do
  @my_obj.bindings.should_not be_empty
end

Then /^@my_obj\.scare\? should be true$/ do
  @my_obj.scare?.should == true
end

Then /^@my_obj\.scare! should cause an event transition$/ do
  @my_obj.state_fu.should == :frightened
  t = @my_obj.scare!
  t.should be_kind_of( StateFu::Transition )
  t.should be_accepted
  @my_obj.state_fu.should == :petrified
end

Then /^(\w+) should respond to '([a-z_]+)' *as an alias for '([a-z_]+)'$/ do |klass, alias_name, meth|
  klass = klass.constantize
  klass.should respond_to(alias_name)
  # this won't work:
  # klass.method(alias_name).should == klass.method(meth)
  # so just test the return value:
  klass.send(alias_name).should == klass.send(meth)
end


Given /^I have required the StateFu library$/ do
  true
end

Then /^it should have a ([a-zA-Z:]+) called :([a-z_]+)$/ do |const, name|
  case const
  when 'StateFu::State'
    @result.states
  when 'StateFu::Event'
    @result.events
  end[name.to_sym].should be_kind_of(const.constantize)
end

When /^I call$/ do |string|
  @result = eval(string)
end

When /^I \w* ?included? StateFu in a class called (\w+)$/ do |klass|
  make_pristine_class klass
  Object.const_get(klass).send(:include, StateFu)
end

When /^I call the class method (\w+)\.(\w+)$/ do |klass, meth|
  @result = Object.const_get(klass).send(meth)
end

Then /^I should get a ([a-zA-Z:]+)$/ do |const|
  @result.should be_kind_of( const.constantize )
end

Given /^I have defined an empty default machine for MyClass$/ do
  MyClass.machine()
end

Then /^the event's ([a-z_]+) should be the ([a-zA-Z:]+) called :([a-z_]+)$/ do |meth, klass, name|
  @event.should be_kind_of( StateFu::Event )
  x = @event.send(meth)
  x.should be_kind_of( klass.constantize )
  x.name.should == name.to_sym
end

Then /sanity check/ do
  # do some debugging
end

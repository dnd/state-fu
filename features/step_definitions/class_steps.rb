# encoding: utf-8
require 'spec/expectations'
$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'state-fu'

Before do
  @result = :false
  Zen::Space.forget!
end

Given /^there is an empty class (.*)$/ do |klass|
  Object.class_eval "class #{klass}; end"
end

Given /^class (.*) includes Zen$/ do |klass|
  Object.const_get( klass ).send :include, Zen
end

Given /^(.*)\.koan\.path\(\) \{\} is called$/ do |klass|
  Object.const_get( klass ).send(:koan).send(:koan)
end

Given /^I have an instance of (.*) called (.*)$/ do |klass, inst|
  instance_variable_set(inst, Object.const_get(klass).new() )
end

Given /^an empty path is defined for class (.*)$/ do |klass|
  pending
end

## When

When /^I call the class method (.*)\.zen$/ do |klass|
  Object.const_get( klass ).send( :zen )
end

When /^I call (@[^\.]+)\.([^\.]+)\(\)$/ do |inst, method|
  @result = instance_variable_get( inst ).send(method)
end

When /^I call ([^@\.]+)\.koan\(\) \{\}$/ do |klass|
  @result = Object.const_get(klass).send(:koan, &lambda{} )
end

When /^I call ([^@\.]+)\.([^\.]+)\(\)$/ do |klass, method|
  @result = Object.const_get(klass).send(method)
end

## Then
Then /^the result should be a (.*)$/ do |const|
  @result.should be_kind_of( const.constantize )
end

Then /^the result should be nil$/ do
  @result.should be_nil
end


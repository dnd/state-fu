#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__),'spec_helper')

begin
  require 'rr'
rescue LoadError => e
  STDERR.puts "The '#{gem_name}' gem is required to run StateFu's specs. Please install it by running (as root):\ngem install #{gem_name}\n\n"
  exit 1;
end

Spec::Runner.configure do |config|
  config.mock_with :rr
end

#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__),'spec_helper')

begin
  require 'rr'
rescue LoadError => e
  STDERR.puts "The 'rr' gem is required to run StateFu's specs. Please install it by running (as root):\n sudo gem install rr\n\n"
  exit 1;
end

Spec::Runner.configure do |config|
  config.mock_with :rr
end

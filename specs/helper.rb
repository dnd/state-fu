$LOAD_PATH.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib"))

require "rubygems"
require "spec"
require "zen"

module Spec::Expectations::ZenExpectations
end

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

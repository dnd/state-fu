require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::FuSpace.reset!

##
##
##

describe "A pristine class Klass with StateFu included:" do
  include MySpecHelper
  before(:each) do
    make_pristine_class 'Klass'
  end

end
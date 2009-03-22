require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Defining a Koan with one state" do
  include MySpecHelper

  before(:each) do
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  it "Should allow me to call state(:hello_world) in the block passed to koan" do
    -> {Klass.koan(){ state :hello_world } }.should_not raise_error()
  end

  describe "having called state(:hello_world) in the block passed to a koan" do
    before(:each) do
      Klass.koan(){ state :hello_world }
    end

    it "should return [:hello_world] given koan.state_names" do
      Klass.koan.should respond_to(:state_names)
      Klass.koan.state_names.should == [:hello_world]
    end

    it "should return [<Zen::State>] given koan.states" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should be_kind_of( Zen::State )
    end

    it "should return :hello_world given koan.states.first.name" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should respond_to(:name)
      Klass.koan.states.first.name.should == :hello_world
    end

  end
end

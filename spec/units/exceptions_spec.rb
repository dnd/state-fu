require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::RequirementError do

  describe "constructor" do
    before do
      @transition = Object.new()
    end

  end
end

describe StateFu::TransitionHalted do

  describe "constructor" do
    before do
      @transition = Object.new()
    end

    it "should create a TransitionHalted given a transition" do
      pending
      e = StateFu::TransitionHalted.new( @transition )
      e.should be_kind_of( StateFu::TransitionHalted )
    end

    it "should allow a custom message" do
      pending
      msg = 'helo'
      e = StateFu::TransitionHalted.new( @transition, msg )
      e.should be_kind_of( StateFu::TransitionHalted )
      e.message.should == msg
    end

    it "should allow a message to be omitted" do
      pending
      e = StateFu::TransitionHalted.new( @transition )
      e.should be_kind_of( StateFu::TransitionHalted )
      e.message.should == StateFu::TransitionHalted::DEFAULT_MESSAGE
    end

    it "should allow access to the transition" do
      pending
      e = StateFu::TransitionHalted.new( @transition )
      e.transition.should == @transition
    end
  end
end

describe StateFu::IllegalTransition do
  before do
    @binding = Object.new
    @origin  = Object.new
    @event   = Object.new
    @target  = Object.new
  end

  describe "constructor" do
    it "should create an IllegalTransition given a binding, event, origin & target" do
      pending
      e = StateFu::IllegalTransition.new( @binding, @event, @origin, @target )
      e.should be_kind_of( StateFu::IllegalTransition )
      e.message.should == StateFu::IllegalTransition::DEFAULT_MESSAGE
    end

    it "should allow a custom message" do
      pending
      msg = 'helo'
      e = StateFu::IllegalTransition.new( @binding, @event, @origin, @target, msg )
      e.should be_kind_of( StateFu::IllegalTransition )
      e.message.should == msg
    end

    it "should allow access to the binding, event, origin, and target" do
      pending
      e = StateFu::IllegalTransition.new( @binding, @event, @origin, @target )
      e.binding.should == @binding
      e.event.should   == @event
      e.origin.should  == @origin
      e.target.should  == @target
    end
  end
end

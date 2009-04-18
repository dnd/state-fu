require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::MethodFactory do
  include MySpecHelper

  # TODO - move to eg method_factory integration spec
  describe "event_methods" do

    before do
      make_pristine_class('Klass')
      @machine = Klass.machine do
        event( :simple_enough, :from => :intro, :to => :outro )
        event( :too_complex, :from => :rocket_science, :to => [:moonwalking, :tax_returns] )
      end
      @obj     = Klass.new
      @binding = @obj.state_fu
    end

    describe "default - define simple event methods on binding" do

      # TODO - split this up into units

      it "should add a ? method for each simple event which is true when the event is valid" do
        @machine.events[:simple_enough].should be_simple

        @binding.should respond_to(:simple_enough?)
        @obj.state_fu.state.should == @machine.states[:intro]
        @binding.fireable?( :simple_enough ).should == true

        e = @machine.events[:simple_enough]
        @binding.valid_transitions[e].should be_kind_of( Array )
        @binding.valid_transitions[e].length.should == 1
        @binding.valid_transitions[e].should include( @machine.states[:outro] )
        @binding.simple_enough?.should == true

        stub( @machine.states[:outro] ).enterable_by?( @binding ) { false }
        @binding.fireable?( :simple_enough ).should == false
        @binding.simple_enough?.should == false
      end

      it "should add instance methods to the binding to fire each simple event" do
        @machine.events[:simple_enough].should be_simple
        @binding.should respond_to(:simple_enough!)
        @binding.current_state.should == @machine.states[:intro]

        e = @machine.events[:simple_enough]
        mock.proxy( @binding ).fire!( e, :argybargy )
        t = @binding.simple_enough!( :argybargy )

        t.should be_kind_of( StateFu::Transition )
        t.event.should == e
        t.origin.should == @machine.states[:intro]
        t.target.should == @machine.states[:outro]
        t.should be_accepted
        @binding.current_state.should == @machine.states[:outro]
      end

      it "should not add instance methods to the binding for complex events" do
        @machine.events[:too_complex].should_not be_simple
        @binding.should_not respond_to(:too_complex!)
      end

      it "should not clobber an existing method"
    end # default - simple binding event methods

    describe "default - define simple event methods on stateful object" do

      it "should add instance methods to the stateful object to fire each simple event" do
        @machine.events[:simple_enough].should be_simple
        @obj.should respond_to( :simple_enough! )
      end

      it "should not add instance methods to the stateful object for complex events" do
        @machine.events[:too_complex].should_not be_simple
        @obj.should_not respond_to(:too_complex!)
      end

      it "should add a query method for each simple event which is true when the event is valid" do
        @machine.events[:simple_enough].should be_simple
        @obj.should respond_to(:simple_enough?)
        @obj.simple_enough?.should == true
        stub( @machine.states[:outro] ).enterable_by?( @binding ) { false }
        @obj.simple_enough?.should == false
      end

      it "should add a query method for events with multiple targets, which takes the targets as its sole argument and  is true when the event is valid" do
        @machine.events[:too_complex].should_not be_simple
        @obj.should respond_to(:too_complex?)
        lambda { @obj.too_complex? }.should raise_error( ArgumentError ) # needs to be told the targets
        lambda { @obj.too_complex?(:tax_returns) }.should_not raise_error()

        @binding.fireable?( [:too_complex, :tax_returns] ).should == true
        @obj.too_complex?(:tax_returns).should == true
        stub( @machine.states[:tax_returns] ).enterable_by?( @binding ) { false }
        @obj.too_complex?(:tax_returns).should == false
      end

      it "should add instance methods to the stateful instance to fire each simple event"
      it "should not add instance methods to the binding for complex events"
      it "should not clobber an existing method"
    end # default - stateful object simple event methods
  end # event methods
end

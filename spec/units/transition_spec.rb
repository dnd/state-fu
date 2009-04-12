require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::Transition do
  include MySpecHelper
  before do
    reset!
    make_pristine_class("Klass")
  end

  describe "A simple machine with 2 states and a single event" do
    before do
      @machine = Klass.machine do
        state :src do
          event :transfer, :to => :dest
        end
      end
      @origin = @machine.states[:src]
      @target = @machine.states[:dest]
      @event  = @machine.events.first
      @obj    = Klass.new
    end

    it "should have two states named :src and :dest" do
      @machine.states.length.should == 2
      @machine.states.should        == [@origin, @target]
      @origin.name.should           == :src
      @target.name.should           == :dest
      @machine.state_names.should   == [:src, :dest]
    end

    it "should have one event :transfer, from :src to :dest" do
      @machine.events.length.should == 1
      @event.origin.should          == [@origin]
      @event.target.should          == [@target]
    end

    describe "instance methods on the transition" do
      before do
        @t = @obj.state_fu.transition( :transfer )
      end

      describe "calling fire! on a transition with no complications" do
        it "should change the state of the binding" do
          @obj.state_fu.state.should == @origin
          @t.fire!
          @obj.state_fu.state.should == @target
        end

        it "should change the field when persistence is via an attribute" do
          @obj.state_fu.persister.should be_kind_of( StateFu::Persistence::Attribute )
          @obj.state_fu.persister.field_name.should == :om_state
          @obj.send( :om_state ).should == "src"
          @t.fire!
          @obj.send( :om_state ).should == "dest"
        end

        it "should define any methods declared in a block given to .transition" do
          trans = @obj.state_fu.fire!( :transfer ) do
            def snoo
              return [self]
            end
          end
          trans.should be_kind_of( StateFu::Transition )
          trans.should respond_to(:snoo)
          trans.snoo.should == [trans]
        end
      end # transition.fire!
    end # transition instance methods

    # binding instance methods
    describe "instance methods on the binding" do
      describe "constructing a new transition with state_fu.transition" do
        it "should create a new transition given an event_name" do
          trans = @obj.state_fu.transition( :transfer )
          trans.should be_kind_of( StateFu::Transition )
          trans.binding.should == @obj.state_fu
          trans.object.should  == @obj
          trans.origin.should  == @origin
          trans.target.should  == @target
          trans.target.should  == @target
          trans.options.should == {}
          trans.errors.should  == []
          trans.args.should    == []
        end

        it "should create a new transition given a StateFu::Event" do
          e = @obj.state_fu.machine.events.first
          e.name.should == :transfer
          trans = @obj.state_fu.transition( e )
          trans.should be_kind_of( StateFu::Transition )
          trans.binding.should == @obj.state_fu
          trans.object.should  == @obj
          trans.origin.should  == @origin
          trans.target.should  == @target
          trans.target.should  == @target
          trans.options.should == {}
          trans.errors.should  == []
          trans.args.should    == []
        end

        it "should be a live? transition, not a test?" do
          trans = @obj.state_fu.transition( :transfer )
          trans.should be_live
          trans.should_not be_test
        end

        it "should define any methods declared in a block given to .transition" do
          trans = @obj.state_fu.transition( :transfer ) do
            def snoo
              return [self]
            end
          end
          trans.should be_kind_of( StateFu::Transition )
          trans.should respond_to(:snoo)
          trans.snoo.should == [trans]
        end
      end # state_fu.transition

      describe "state_fu.events" do
        it "should be an array with the only event as its single element" do
          @obj.state_fu.events.should == [@event]
        end
      end

      describe "state_fu.fire!( :transfer )" do
        it "should change the state when called" do
          @obj.state_fu.should respond_to( :fire! )
          @obj.state_fu.state.should == @origin
          @obj.state_fu.fire!( :transfer )
          @obj.state_fu.state.should == @target
        end

        it "should return a transition object" do
          @obj.state_fu.fire!( :transfer ).should be_kind_of( StateFu::Transition )
        end

      end # state_fu.fire!

      describe "calling cycle!" do
        it "should raise an InvalidTransition error" do
          lambda { @obj.state_fu.cycle!() }.should raise_error( StateFu::InvalidTransition )
        end
      end # cycle!

      describe "calling next!" do
        it "should change the state" do
          @obj.state_fu.state.should == @origin
          @obj.state_fu.next!()
          @obj.state_fu.state.should == @target
        end
      end # cycle!

    end  # binding instance methods
  end # simple machine w/ 2 states, 1 transition

end

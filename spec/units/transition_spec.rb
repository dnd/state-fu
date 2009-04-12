require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::Transition do
  include MySpecHelper
  before do
    reset!
    make_pristine_class("Klass")
  end

  describe "Simple two state transition" do
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
      @machine.states.should == [@origin, @target]
      @origin.name.should == :src
      @target.name.should == :dest
      @machine.state_names.should == [:src, :dest]
    end

    it "should have one event :transfer, from :src to :dest" do
      @machine.events.length.should == 1
      @event.origin.should == [@origin]
      @event.target.should == [@target]
    end

    describe "constructing a new transition" do
    end

    describe "constructing a new transition" do
      it "should create a new transition given @obj.state_fu.transition( event_name )" do
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
    end

    describe "calling fire! on a transition with no complications" do
      before do
        @t = @obj.state_fu.transition( :transfer )
      end

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
    end

    describe "calling fire!( :transfer ) on the binding" do
      it "should change the state when called" do
        @obj.state_fu.should respond_to( :fire! )
        @obj.state_fu.state.should == @origin
        @obj.state_fu.fire!( :transfer )
        @obj.state_fu.state.should == @target
      end

      it "should return a transition object" do
        @obj.state_fu.fire!( :transfer ).should be_kind_of( StateFu::Transition )
      end

    end
  end # simple machine w/ 2 states, 1 transition
end

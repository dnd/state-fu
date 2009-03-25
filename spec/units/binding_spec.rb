require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe StateFu::Binding do
  include MySpecHelper

  before do
    reset!
    make_pristine_class('Klass')
    Klass.machine(){}
    @obj = Klass.new()
  end

  describe "initialization via @obj.om()" do
    it "should create a new StateFu::Binding" do
      mdn = @obj.om()
      mdn.should be_kind_of( StateFu::Binding )
      mdn.machine.should == Klass.machine
      mdn.machinist.should == @obj
      mdn.method_name.should == :om
      mdn.field_name.should  == :om_state
    end
  end

  describe "constructor" do
    it "should create a new Binding given valid arguments" do
      pending
    end
  end

  describe "For Klass.machine() with two states and an event" do
    before do
      reset!
      make_pristine_class('Klass')
      Klass.machine do
        state :new do
          event :age, :to => :old
        end
        state :old
        # initial_state :fetus
      end
      @machine   = Klass.machine()
      @object = Klass.new()
      @om     = @object.om()
    end

    it "should be sane (checking Machine for sanity)" do
      machine = @om.machine
      machine.states.length.should == 2
      machine.state_names.should == [:new, :old]
      machine.events.length.should == 1
      machine.events.first.origin.should_not be_nil
      machine.events.first.target.should_not be_nil
    end


    describe ".state()" do
      it "should default to machine.initial_state when no initial_state is explicitly defined" do
        @om.respond_to?(:current_state).should == true
        @om.current_state.should be_kind_of( StateFu::State )
        @om.current_state.name.should == :new
        @om.machine.initial_state.name.should == :new
      end

      it "should default to the machine's initial_state if one is set" do
        Klass.machine() { initial_state :fetus }
        Klass.machine.states.first.name.should      == :new
        Klass.machine.initial_state.name.should     == :fetus
        Klass.new().om.current_state.name.should == :fetus
      end

    end
  end


  describe "Instance methods" do
    before do

    end

  end
end

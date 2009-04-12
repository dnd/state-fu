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

  describe "constructor" do
    it "should create a new Binding given valid arguments" do
      mock( StateFu::FuSpace ).field_names() do
        {
          Klass => { :example => :example_field }
        }
      end
      b = StateFu::Binding.new( Klass.machine, @obj, :example )
      b.should be_kind_of( StateFu::Binding )
      b.object.should      == @obj
      b.machine.should     == Klass.machine
      b.method_name.should == :example
    end
  end

  describe "initialization via @obj.binding()" do
    it "should create a new StateFu::Binding with default method-name & field_name" do
      b = @obj.binding()
      b.should be_kind_of( StateFu::Binding )
      b.machine.should == Klass.machine
      b.object.should == @obj
      b.method_name.should == :om
      b.field_name.should  == :om_state
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
      @object    = Klass.new()
      @binding   = @object.stfu()
    end

    it "should be sane (checking Machine for sanity)" do
      machine = @binding.machine
      machine.states.length.should == 2
      machine.state_names.should == [:new, :old]
      machine.events.length.should == 1
      machine.events.first.origin.should_not be_nil
      machine.events.first.target.should_not be_nil
    end

    describe "firing events" do
      describe "fire! method" do

      end
    end

    describe ".state()" do
      it "should default to machine.initial_state when no initial_state is explicitly defined" do
        @binding.respond_to?(:current_state).should == true
        @binding.current_state.should be_kind_of( StateFu::State )
        @binding.current_state.name.should == :new
        @binding.machine.initial_state.name.should == :new
      end

      it "should default to the machine's initial_state if one is set" do
        Klass.machine() { initial_state :fetus }
        Klass.machine.states.first.name.should   == :new
        Klass.machine.initial_state.name.should  == :fetus
        Klass.new().binding.current_state.name.should == :fetus
      end
    end

  end

  describe "Instance methods" do
    before do

    end

  end
end

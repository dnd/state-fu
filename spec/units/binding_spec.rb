require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::Binding do
  include MySpecHelper

  describe "instance methods" do
  end

  #
  # class methods
  #

  describe "class methods" do
  end


  #
  #
  #



  #
  #
  #

  before do
    reset!
    make_pristine_class('Klass')
    Klass.machine(){}
    @obj = Klass.new()
  end

  describe "constructor" do
    before do
      mock( StateFu::FuSpace ).field_names.at_most(1) do
        {
          Klass => { :example => :example_field }
        }
      end
    end

    it "should create a new Binding given valid arguments" do
      b = StateFu::Binding.new( Klass.machine, @obj, :example )
      b.should be_kind_of( StateFu::Binding )
      b.object.should      == @obj
      b.machine.should     == Klass.machine
      b.method_name.should == :example
    end

    it "should add any options supplied to the binding" do
      b = StateFu::Binding.new( Klass.machine, @obj, :example,
                                :colour => :red,
                                :style  => [:robust, :fruity] )
      b.options.should == { :colour => :red, :style  => [:robust, :fruity] }
    end

    describe "persister initialization" do
      before do
        @p = Object.new
        class << @p
          attr_accessor :field_name
        end
        @p.field_name
      end

      describe "when StateFu::Persistence.active_record_column? is true" do
        before do
          mock( StateFu::Persistence ).active_record_column?(Klass, :example_field).times(1) { true }
          mock( Klass ).before_create( :state_fu!) { }          
        end
        it "should get an ActiveRecord persister" do
          mock( StateFu::Persistence::ActiveRecord ).new( anything, :example_field ) { @p }
          b = StateFu::Binding.new( Klass.machine, @obj, :example )
          b.persister.should == @p
        end
      end

      describe "when StateFu::Persistence.active_record_column? is false" do
        before do
          mock( StateFu::Persistence ).active_record_column?(Klass, :example_field) { false }
        end
        it "should get an Attribute persister" do
          mock( StateFu::Persistence::Attribute ).new( anything, :example_field ) { @p }
          b = StateFu::Binding.new( Klass.machine, @obj, :example )
          b.persister.should == @p
        end
      end
    end
  end

  describe "initialization via @obj.state_fu()" do
    it "should create a new StateFu::Binding with default method-name & field_name" do
      b = @obj.state_fu()
      b.should be_kind_of( StateFu::Binding )
      b.machine.should == Klass.machine
      b.object.should == @obj
      b.method_name.should == :state_fu
      b.field_name.should  == :state_fu_field
    end
  end

  describe "a binding for the default machine with two states and an event" do
    before do
      reset!
      make_pristine_class('Klass')
      Klass.machine do
        state :new do
          event :age, :to => :old
        end
        state :old
      end
      @machine   = Klass.machine()
      @object    = Klass.new()
      @binding   = @object.state_fu()
    end

    describe "==" do
      it "should be == :new" do
        @binding.should == :new
      end
    end

    describe ".state and .initial_state" do
      it "should default to machine.initial_state when no initial_state is explicitly defined" do
        @machine.initial_state.name.should == :new
        @binding.current_state.should == @machine.initial_state
      end

      it "should default to the machine's initial_state if one is set" do
        @machine.initial_state = :fetus
        @machine.initial_state.name.should == :fetus
        obj = Klass.new
        obj.state_fu.current_state.should == @machine.initial_state
      end
    end

  end

  describe "Instance methods" do
    before do
    end
    describe "fireable?" do
      before do
        reset!
        make_pristine_class("Klass")
        Klass.class_eval do
          def tissue?(*args); true; end
        end
        @machine = Klass.machine do
          state :snoo do
            event :am_fireable, :to => :wizz do
              requires :tissue?
            end
          end
          state :wizz do
            event :not_fireable, :to => :pong
          end
        end
        @obj = Klass.new
      end

      describe "when called with arguments which would return a valid transition from .transition()" do
        it "should return true" do
          @obj.state_fu.fireable?(:am_fireable).should == true
        end
      end

      describe "when called with arguments which would raise an InvalidTransition from .transition()" do
        it "should return nil" do
          @obj.state_fu.name.should == :snoo
          lambda { @obj.state_fu.transition(:not_fireable) }.should raise_error( StateFu::InvalidTransition )
          lambda { @obj.state_fu.fireable?(:not_fireable) }.should_not raise_error( StateFu::InvalidTransition )
          @obj.state_fu.fireable?(:not_fireable).should == nil
        end
      end

      describe "when called with additional arguments after the destination event/state" do

        # This would make very little sense to someone trying to understand how to use the library.
        it "should pass the arguments to any requirements to determine transition availability" do          
          set_method_arity( @obj, :tissue?, needed_arity = 1 )
          mock(@obj).tissue?(is_a(StateFu::Transition)) {|t| t.args.should == [:a,:b] }
          @obj.state_fu.fireable?(:am_fireable, :a, :b)
        end 
      end

    end

  end
end

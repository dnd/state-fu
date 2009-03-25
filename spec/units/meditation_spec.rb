require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe StateFu::Meditation do
  include MySpecHelper

  before do
    reset!
    make_pristine_class('Klass')
    Klass.koan(){}
    @obj = Klass.new()
  end

  describe "initialization via @obj.om()" do
    it "should create a new StateFu::Meditation" do
      mdn = @obj.om()
      mdn.should be_kind_of( StateFu::Meditation )
      mdn.koan.should == Klass.koan
      mdn.disciple.should == @obj
      mdn.method_name.should == :om
      mdn.field_name.should  == :om_state
    end
  end

  describe "constructor" do
    it "should create a new Meditation given valid arguments" do
      pending
    end
  end

  describe "For Klass.koan() with two states and an event" do
    before do
      reset!
      make_pristine_class('Klass')
      Klass.koan do
        state :new do
          event :age, :to => :old
        end
        state :old
        # initial_state :fetus
      end
      @koan   = Klass.koan()
      @object = Klass.new()
      @om     = @object.om()
    end

    it "should be sane (checking Koan for sanity)" do
      koan = @om.koan
      koan.states.length.should == 2
      koan.state_names.should == [:new, :old]
      koan.events.length.should == 1
      koan.events.first.origin.should_not be_nil
      koan.events.first.target.should_not be_nil
    end


    describe ".state()" do
      it "should default to koan.initial_state when no initial_state is explicitly defined" do
        @om.respond_to?(:current_state).should == true
        @om.current_state.should be_kind_of( StateFu::State )
        @om.current_state.name.should == :new
        @om.koan.initial_state.name.should == :new
      end

      it "should default to the koan's initial_state if one is set" do
        Klass.koan() { initial_state :fetus }
        Klass.koan.states.first.name.should      == :new
        Klass.koan.initial_state.name.should     == :fetus
        Klass.new().om.current_state.name.should == :fetus
      end

    end
  end


  describe "Instance methods" do
    before do

    end

  end
end

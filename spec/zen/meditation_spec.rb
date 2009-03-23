require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe Zen::Meditation do
  include MySpecHelper

  before do
    reset!
    make_pristine_class('Klass')
    Klass.koan(){}
    @obj = Klass.new()
  end

  describe "initialization via @obj.om()" do
    it "should create a new Zen::Meditation" do
      mdn = @obj.om()
      mdn.should be_kind_of( Zen::Meditation )
      mdn.koan.should == Klass.koan
      mdn.disciple.should == @obj
      mdn.method_name.should == :om
      mdn.field_name.should == :om_state
    end
  end
  describe "constructor" do
    it "should create a new Meditation given valid arguments" do
      pending
    end
  end

  describe "For a class' default Koan which has two states and a method" do
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

    describe "For a non-ActiveRecord class" do
      describe ".state()" do
        it "initial current_state" do
          @om.respond_to?(:current_state).should == true
          @om.current_state.should be_kind_of( Zen::State )
          @om.current_state.name.should == :new
        end
      end
    end
  end


  describe "Instance methods" do
    before do

    end

  end
end

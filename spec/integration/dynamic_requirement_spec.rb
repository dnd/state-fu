require File.expand_path("#{File.dirname(__FILE__)}/../helper")

module MySpecHelper
  module DynamicTransitionObjectInstanceMethods
    def method_which_expects_nothing_passed_to_it()
      true
    end

    def method_which_requires_one_arg( t )
      t.args.length == 1
    end

    def given_any_arg?( t = nil )
      t.is_a?( StateFu::Transition ) && !t.args.empty?
    end

    def falsey?( t = nil )
      t.is_a?( StateFu::Transition ) && !t.args.empty? && t.args.first == false
    end

    def truthy?( t = nil )
      t.is_a?( StateFu::Transition ) && !t.args.empty? && t.args.first == true
    end

    def method_which_always_returns_true( t = nil )
      true
    end

    def method_which_always_returns_false( t = nil )
      false
    end
  end
end

describe "Transition requirement evaluation with dynamic conditions" do
  include MySpecHelper

  before do
    reset!
    make_pristine_class("Klass")

    Klass.send :include, MySpecHelper::DynamicTransitionObjectInstanceMethods

    @machine = Klass.state_fu_machine do

      state :default do
        requires :method_which_requires_one_arg, :on => [:entry, :exit]

        cycle do
          requires :method_which_requires_one_arg
        end

        event :truthify, :to => :truth do
          requires :truthy?
        end

        event :falsify, :to => :falsehood do
          requires :falsey?
          requires :method_which_expects_nothing_passed_to_it
        end

        #event :impossify, :to => :impossible do
         # requires :method_which_always_returns_false
        #end

      end
    end
    @obj = Klass.new
    @fu  = @obj.state_fu # binding
    # Because RR changes the arity of the method on @obj we need to do this:
    # stub( @fu ).limit_arguments( anything ) { |t| t }
  end

  describe "a requirement that the transition was given one arg" do

    describe "object.cycle?()" do

      it "should return false given no args" do
        @fu.cycle?().should == false
      end

      it "should be true given one arg" do
        @fu.cycle?(1).should == true
      end

      it "should be false given two args" do
        @fu.cycle?(1,2).should == false
      end
    end

    it "should evaluate the requirement by passing it a transition when requirements_met? is called" do
      t = @fu.cycle()
      # mock.proxy( @fu ).evaluate_requirement_with_transition(:method_which_requires_one_arg, t ).at_least(2)
      t.requirements_met?.should == false
      t.args = [1]
      t.requirements_met?.should == true
    end

    describe "binding.evaluate_requirement_with_args" do

    end

    describe "valid_transitions" do
      describe "given no arguments" do
        it "should return {}" do
          @fu.valid_transitions.should == {}
        end
      end

      it "should pass each requirement method a transition object with no args" do
      end

      it "should call method_which_requires_one_arg given call_on_object_with_optional_args(:method_which_requires_one_arg .. )" do
        t = @fu.blank_mock_transition( :first_arg )
        @obj.respond_to?(:method_which_requires_one_arg).should be_true
        meth = @obj.method(:method_which_requires_one_arg)
        meth.arity.should == 1
        @fu.limit_arguments( meth, t ).should == [t]
        @fu.call_on_object_with_optional_args( :method_which_requires_one_arg, t )
      end

      it "should call method_which_requires_one_arg with a mock transition with one argument" do
        t = @fu.blank_mock_transition( :first_arg )
        # mock( @obj ).method_which_requires_one_arg( t )
        @fu.call_on_object_with_optional_args( :method_which_requires_one_arg, t ).should == true
      end

      it "should contain the :cycle_default event only if an arg is supplied" do
        @fu.should == :default
        ves = @fu.valid_events( )
        ves.length.should == 0
        ves = @fu.valid_events( 1 )
        ves.length.should == 1
        ves.first.should == @machine.events[:cycle_default]

        @machine.events[:cycle_default].target.should == @fu.current_state
        @fu.evaluate_requirement_with_args( :method_which_requires_one_arg ).should == false
        @fu.evaluate_requirement_with_args( :method_which_requires_one_arg, 1 ).should == true
        @fu.current_state.enterable_by?( @fu ).should == false
        @fu.current_state.enterable_by?( @fu, 1 ).should == true

        vts = @fu.valid_transitions()
        vts.should be_kind_of( Hash )
        vts.should be_empty
        vts = @fu.valid_transitions( 1 )
        vts.should_not be_empty
        vts.length.should  == 1
        vts.keys.first.should   == @machine.events[:cycle_default]
        vts.values.first.should == [@machine.states[:default]]
      end

      it "should pass method_which_requires_one_argument() a transition with no arguments" do
        # mock.proxy( @obj ).method_which_requires_one_arg( is_a(StateFu::MockTransition) ).times(3)
        @fu.valid_transitions( 1 )
      end

    end
  end

end

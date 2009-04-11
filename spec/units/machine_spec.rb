require File.expand_path("#{File.dirname(__FILE__)}/../helper")

## See state_and_event_common_spec.rb for behaviour shared between
## StateFu::State and StateFu::Event
##

describe StateFu::Machine do
  include MySpecHelper

  before do
  end

  describe "class methods" do
    before do

    end

    describe "Machine.for_class" do
      describe "when there's no matching machine in FuSpace" do
        before do
          reset!
          make_pristine_class 'Klass'
          mock( StateFu::FuSpace ).class_machines() { { Klass => {} } }
        end

        it "should create a new machine and bind! it" do
          @machine = Object.new
          mock( @machine ).bind!( Klass, :moose, nil )
          mock( StateFu::Machine ).new( :moose, {} ) { @machine }
          StateFu::Machine.for_class( Klass, :moose )
        end

        it "should apply the block if one is given"
      end

      describe "when there's a matching machine in FuSpace" do
        before do
          reset!
          make_pristine_class 'Klass'
          @machine = Object.new
          mock( StateFu::FuSpace ).class_machines() { { Klass => { :moose => @machine } } }
        end

        it "should retrieve the previously created machine" do
          StateFu::Machine.for_class( Klass, :moose ).should == @machine
        end

        it "should apply the block if one is given"
      end

    end
  end

  describe "instance methods" do
    before do
      @mchn = StateFu::Machine.new( :spec_machine, options={} )
    end

    describe "helper" do
      it "should add its arguments to the @@helpers array" do
        module Foo; FOO = :foo; end
        module Bar; BAR = :bar; end
        @mchn.helper Foo, Bar
        @mchn.helpers.should == [Foo, Bar]
      end

    end

    describe ".initialize" do
      it "should require a name" do
        lambda do
          StateFu::Machine.new()
        end.should raise_error( ArgumentError )
      end
    end

    describe ".apply!" do
      it "..."
    end

    describe ".bind!" do
      it "..."
    end

    describe ".initial_state=" do
      it "..."
    end

    describe ".initial_state" do
      it "..."
    end

    describe ".states" do
      it "..."
    end

    describe ".state_names" do
      it "..."
    end

    describe ".events" do
      it "..."
    end

    describe ".event_names" do
      it "..."
    end

    describe ".define_state" do
      it "..."
    end

    describe ".define_event" do
      it "..."
    end

    describe ".find_or_create_states_by_name" do
      it "..."
    end

  end

end

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
        # dont know how to spec this
      end

      describe "when there's a matching machine in FuSpace" do
        before do
          @machine = Object.new
          mock( StateFu::FuSpace ).class_machines() { { Klass => { :moose => @machine } } }
        end

        it "should retrieve the previously created machine" do
          StateFu::Machine.for_class( Klass, :moose ).should == @machine
        end

        it "should apply the block if one is given"
        # dont know how to spec this
      end

    end
  end

  describe "attributes" do
  end

  describe "instance methods" do
    before do
      reset!
      make_pristine_class 'Klass'
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

    end

    describe ".bind!" do
      it "should call StateFu::FuSpace.insert! with itself and its arguments" do
        field_name = :my_field_name
        mock( StateFu::FuSpace ).insert!( Klass, @mchn, :newname, field_name ) {}
        @mchn.bind!( Klass, :newname, field_name )
      end

      it "should generate a field name if none is given" do
        klass      = Klass
        name       = :StinkJuice
        field_name = 'stink_juice_field'
        mock( StateFu::FuSpace ).insert!( Klass, @mchn, name, field_name.to_sym ) {}
        @mchn.bind!( Klass, name )
      end
    end

    describe ".initial_state=" do

      it "should set @initial_state given a String, Symbol or State for an existing state" do
        state = StateFu::State.new( @mchn, :wizzle )
        @mchn.states << state
        @mchn.initial_state = state
        @mchn.initial_state.should == state
      end

      it "should create the state if it doesnt exist" do
        @mchn.initial_state = :snoo
        @mchn.initial_state.should be_kind_of( StateFu::State )
        @mchn.initial_state.name.should == :snoo
        @mchn.states.should include( @mchn.initial_state )
      end

      it "should raise an ArgumentError given a number or an Array" do
        lambda do @mchn.initial_state = 6
        end.should raise_error( ArgumentError )

        lambda do @mchn.initial_state = [:ping]
        end.should raise_error( ArgumentError )
      end

    end

    describe ".initial_state" do
      it "should return nil if there are no states and initial_state= has not been called" do
        @mchn.states.should == []
        @mchn.initial_state.should == nil
      end

      it "should return the first state if one exists" do
        stub( @mchn ).states() {  [:a, :b, :c] }
        @mchn.initial_state.should == :a
      end

    end

    describe ".states" do
      it "should return an array extended with StateFu::StateArray" do
        @mchn.states.should be_kind_of( Array )
        @mchn.states.extended_by.should include( StateFu::StateArray )
      end
    end

    describe ".state_names" do
      it "should return a list of symbols of state names" do
        @mchn.states << StateFu::State.new( @mchn, :a )
        @mchn.states << StateFu::State.new( @mchn, :b )
        @mchn.state_names.should == [:a, :b ]
      end
    end

    describe ".events" do
      it "should return an array extended with StateFu::EventArray" do
        @mchn.events.should be_kind_of( Array )
        @mchn.events.extended_by.should include( StateFu::EventArray )
      end
    end

    describe ".event_names" do
      it "should return a list of symbols of event names" do
        @mchn.events << StateFu::Event.new( @mchn, :a )
        @mchn.events << StateFu::Event.new( @mchn, :b )
        @mchn.event_names.should == [:a, :b ]
      end
    end

    describe ".find_or_create_states_by_name" do
      describe "given an array of symbols" do
        it "should return the states named by the symbols if they exist" do
          a = StateFu::State.new( @mchn, :a )
          b = StateFu::State.new( @mchn, :b )
          @mchn.states << a
          @mchn.states << b
          @mchn.find_or_create_states_by_name( :a, :b ).should == [a, b]
          @mchn.find_or_create_states_by_name( [:a, :b] ).should == [a, b]
        end

        it "should return the states named by the symbols and create them if they don't exist" do
          @mchn.states.should == []
          res = @mchn.find_or_create_states_by_name( :a, :b )
          res.should be_kind_of( Array )
          res.length.should == 2
          res.all? { |e| e.class == StateFu::State  }.should be_true
          res.map(&:name).should == [ :a, :b ]
          @mchn.find_or_create_states_by_name( :a, :b ).should == res
        end
      end # arr symbols

      describe "given an array of states" do
        it "should return the states if they're in the machine's states array" do
          a = StateFu::State.new( @mchn, :a )
          b = StateFu::State.new( @mchn, :b )
          @mchn.states << a
          @mchn.states << b
          @mchn.find_or_create_states_by_name( a, b ).should == [a, b]
          @mchn.find_or_create_states_by_name( [a, b] ).should == [a, b]
          @mchn.find_or_create_states_by_name( [[a, b]] ).should == [a, b]
        end

        it "should add the states to the machine's states array if they're absent" do
          a = StateFu::State.new( @mchn, :a )
          b = StateFu::State.new( @mchn, :b )
          @mchn.find_or_create_states_by_name( a, b ).should == [a, b]
          @mchn.find_or_create_states_by_name( [a, b] ).should == [a, b]
          @mchn.find_or_create_states_by_name( [[a, b]] ).should == [a, b]
        end
      end # arr states
    end # find_or_create_states_by_name

    describe "requirement_messages" do
      it "should be a hash" do
        @mchn.should respond_to(:requirement_messages)
        @mchn.requirement_messages.should be_kind_of( Hash )
      end

      it "should be empty by default" do
        @mchn.requirement_messages.should be_empty
      end

    end # requirement_messages

    describe "named_procs" do
      it "should be a hash" do
        @mchn.should respond_to(:named_procs)
        @mchn.named_procs.should be_kind_of( Hash )
      end

      it "should be empty by default" do
        @mchn.named_procs.should be_empty
      end

    end # named_procs

  end # instance methods
end

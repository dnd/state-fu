require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::MethodFactory do
  include MySpecHelper

  # TODO - move to eg method_factory integration spec
  describe "event_methods" do

    before do
      make_pristine_class('Klass')
    end

    describe "defined on the binding" do
      describe "when the event is simple (has only one possible target)" do
        before do
          @machine = Klass.machine do
            event( :simple_event,
                   :from => { [:a, :b] => :targ } )
          end # machine
          @obj     = Klass.new
          @binding = @obj.state_fu
        end # before

        it "should be simple?" do
          e = @machine.events[:simple_event]
          e.origins.length.should == 2
          e.targets.length.should == 1
          e.should be_simple
        end

        describe "method which returns an unfired transition" do
          it "should have the same name as the event" do
            @binding.should respond_to(:simple_event)
          end

          it "should return a new transition if called without any arguments" do
            t = @binding.simple_event()
            t.should be_kind_of( StateFu::Transition )
            t.target.should == @machine.states[:targ]
            t.event.should == @machine.events[:simple_event]
            t.should_not be_fired
          end

          it "should add any arguments / options it is called with to the transition" do
            t = @binding.simple_event(:a, :b, :c, {'d' => 'e'})
            t.should be_kind_of( StateFu::Transition )
            t.target.should == @machine.states[:targ]
            t.event.should == @machine.events[:simple_event]
            t.args.should == [:a,:b,:c]
            t.options.should == {:d => 'e'}
          end
        end # transition builder

        describe "method which tests if the event is fireable?" do
          it "should have the name of the event suffixed with ?" do
            @binding.should respond_to(:simple_event?)
          end

          it "should be true when the binding says it\'s fireable?" do
            @binding.fireable?( :simple_event ).should == true
            @binding.simple_event?.should == true
          end

          it "should be false when the binding says it\'s not fireable?" do
            mock( @binding ).fireable?( anything ) { false }
            @binding.simple_event?.should == false
          end
        end # fireable?

        describe "bang (!) method which creates, fires and returns a transition" do
          it "should have the name of the event suffixed with a bang (!)" do
            @binding.should respond_to(:simple_event!)
          end

          it "should return a fired transition" do
            t = @binding.simple_event!
            t.should be_kind_of( StateFu::Transition )
            t.should be_fired
          end

          it "should pass any arguments to the transition as args / options" do
            t = @binding.simple_event!( :a, :b, {'c' => :d } )
            t.should be_kind_of( StateFu::Transition )
            t.args.should    == [:a, :b ]
            t.options.should == { :c => :d }
          end
        end # bang!
      end # simple

      describe "when the event is complex (has more than one possible target)" do
        before do
          @machine = Klass.machine do
            state :orphan
            event( :complex_event,
                   :from => :home,
                   :to => [ :x, :y, :z ] )
          end # machine
          @obj     = Klass.new
          @binding = @obj.state_fu
        end # before

        it "should not be simple?" do
          e = @machine.events[:complex_event]
          e.origins.length.should == 1
          e.targets.length.should == 3
          e.should_not be_simple
        end

        describe "method which returns an unfired transition" do
          it "should have the same name as the event" do
            @binding.should respond_to(:complex_event)
          end

          it "should raise an error if called without any arguments" do
            lambda { @binding.complex_event() }.should raise_error( ArgumentError )
          end

          it "should raise an ArgumentError if called with a nonexistent target state" do
            lambda { @binding.complex_event(:nonexistent) }.should raise_error( ArgumentError )
          end

          it "should raise an InvalidTransition if called with an invalid target state" do
            lambda { @binding.complex_event(:orphan)      }.should raise_error( StateFu::InvalidTransition )
          end

          it "should return a transition to the specified state if supplied a valid state" do
            t = @binding.complex_event( :x )
            t.should be_kind_of( StateFu::Transition )
            t.target.name.should == :x
          end

          it "should add any arguments / options it is called with to the transition" do
            t = @binding.complex_event(:x,
                                       :a, :b, :c, {'d' => 'e'})
            t.should be_kind_of( StateFu::Transition )
            t.args.should == [:a,:b,:c]
            t.options.should == {:d => 'e'}
          end
        end # transition builder

        describe "method which tests if the event is fireable?" do
          it "should have the name of the event suffixed with ?" do
            @binding.should respond_to(:complex_event?)
          end

          it "should require a valid state name" do
            lambda { @binding.complex_event?(:nonexistent) }.should raise_error( ArgumentError )
            lambda { @binding.complex_event?(:orphan) }.should      raise_error( StateFu::InvalidTransition )
            lambda { @binding.complex_event?(:x) }.should_not       raise_error
          end

          it "should be true when the binding says the event is fireable? " do
            @binding.fireable?( [:complex_event, :x] ).should == true
            @binding.complex_event?(:x).should == true
          end

          it "should be false when the binding says the event is not fireable?" do
            mock( @binding ).fireable?( anything ) { false }
            @binding.complex_event?(:x).should == false
          end
        end # fireable?

        describe "bang (!) method which creates, fires and returns a transition" do
          it "should have the name of the event suffixed with a bang (!)" do
            @binding.should respond_to(:complex_event!)
          end

          it "should require a valid state name" do
            lambda { @binding.complex_event!(:nonexistent) }.should raise_error( ArgumentError )
            lambda { @binding.complex_event!(:orphan) }.should      raise_error( StateFu::InvalidTransition )
            lambda { @binding.complex_event!(:x) }.should_not       raise_error
          end

          it "should return a fired transition given a valid state name" do
            t = @binding.complex_event!( :x )
            t.should be_kind_of( StateFu::Transition )
            t.target.should == @machine.states[:x]
            t.should be_fired
          end

          it "should pass any arguments to the transition as args / options" do
            t = @binding.complex_event!( :x,
                                         :a, :b, {'c' => :d } )
            t.should be_kind_of( StateFu::Transition )
            t.target.should  == @machine.states[:x]
            t.args.should    == [:a, :b ]
            t.options.should == { :c => :d }
          end
        end # bang!
      end # complex_event

      # TODO move these to binding spec
      describe "cycle and next_state methods" do
        describe "when there is a valid transition available for cycle and next_state" do
          before do
            @machine = Klass.machine do
              initial_state :groundhog_day

              state(:groundhog_day) do
                cycle
              end

              event(:end_movie, :from => :groundhog_day, :to => :happy_ending)
            end # machine
            @obj     = Klass.new
            @binding = @obj.state_fu
          end # before

          describe "cycle methods:" do
            describe "cycle" do
              it "should return a transition for the cyclical event"
            end

            describe "cycle?" do
            end

            describe "cycle!" do
            end
          end # cycle

          describe "next_state methods:" do
            describe "next_state" do
            end

            describe "next_state?" do
            end

            describe "next_state!" do
            end
          end # next_state
        end # with valid transitions

        describe "when the machine is empty" do
          before do
            @machine = Klass.machine() {}
            @obj     = Klass.new
            @binding = @obj.state_fu
          end
          describe "cycle methods:" do
            describe "cycle" do
              it "should return nil" do
              end
            end

            describe "cycle?" do
              it "should return nil"
            end

            describe "cycle!" do
              it "should raise ..."
            end
          end # cycle

          describe "next_state methods:" do
            describe "next_state" do
              it "should return nil"
            end

            describe "next_state?" do
              it "should return nil"
            end

            describe "next_state!" do
              it "should raise ..."
            end
          end # next_state

        end # empty machine

        describe "when there is more than one candidate event / state" do
        end # too many candidates

      end   # cycle & next_state
    end     # defined on binding

    describe "methods defined on the object" do
    end

  end       # event methods
end

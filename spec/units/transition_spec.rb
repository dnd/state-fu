require File.expand_path("#{File.dirname(__FILE__)}/../helper")

# TODO - this is really an integration spec and should be moved as appropriate
describe StateFu::Transition do
  include MySpecHelper
  before do
    reset!
    make_pristine_class("Klass")
  end

  #
  #
  #

  describe "A simple machine with 2 states and a single event" do
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
      @machine.states.should        == [@origin, @target]
      @origin.name.should           == :src
      @target.name.should           == :dest
      @machine.state_names.should   == [:src, :dest]
    end

    it "should have one event :transfer, from :src to :dest" do
      @machine.events.length.should == 1
      @event.origin.should          == [@origin]
      @event.target.should          == [@target]
    end

    describe "instance methods on a transition" do
      before do
        @t = @obj.state_fu.transition( :transfer )
      end

      describe "the transition before firing" do
        it "should not be fired" do
          @t.should_not be_fired
        end

        it "should not be halted" do
          @t.should_not be_halted
        end

        it "should not be testing" do
          @t.should_not be_test
          @t.should_not be_testing
        end

        it "should be live" do
          @t.should be_live
          @t.should be_real
        end

        it "should not be accepted" do
          @t.should_not be_accepted
        end

        it "should have a current_state of :unfired" do
          @t.current_state.should == :unfired
        end

        it "should have a current_hook of nil" do
          @t.current_hook.should == nil
        end
      end # transition before fire!

      describe "calling fire! on a transition with no conditions or hooks" do
        it "should change the state of the binding" do
          @obj.state_fu.state.should == @origin
          @t.fire!
          @obj.state_fu.state.should == @target
        end

        it "should have an empty set of hooks" do
          @t.hooks.should == []
        end

        it "should change the field when persistence is via an attribute" do
          @obj.state_fu.persister.should be_kind_of( StateFu::Persistence::Attribute )
          @obj.state_fu.persister.field_name.should == :om_state
          @obj.send( :om_state ).should == "src"
          @t.fire!
          @obj.send( :om_state ).should == "dest"
        end
      end # transition.fire!

      describe "the transition after firing is complete" do
        before do
          @t.fire!()
        end

        it "should be fired" do
          @t.should be_fired
        end

        it "should not be halted" do
          @t.should_not be_halted
        end

        it "should not be testing" do
          @t.should_not be_test
          @t.should_not be_testing
        end

        it "should be live" do
          @t.should be_live
          @t.should be_real
        end

        it "should be accepted" do
          @t.should be_accepted
        end

        it "should have a current_state of :accepted" do
          @t.current_state.should == :accepted
        end

        it "should have a current_hook of nil" do
          @t.current_hook.should == nil
        end
      end # transition after fire
    end # transition instance methods

    # binding instance methods
    # TODO move these to binding spec
    describe "instance methods on the binding" do
      describe "constructing a new transition with state_fu.transition" do

        it "should raise an ArgumentError if a bad event name is given" do
          lambda do
            trans = @obj.state_fu.transition( :transfibrillate )
          end.should raise_error( ArgumentError )
        end

        it "should create a new transition given an event_name" do
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

        it "should create a new transition given a StateFu::Event" do
          e = @obj.state_fu.machine.events.first
          e.name.should == :transfer
          trans = @obj.state_fu.transition( e )
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

        it "should be a live? transition, not a test?" do
          trans = @obj.state_fu.transition( :transfer )
          trans.should be_live
          trans.should_not be_test
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
      end # state_fu.transition

      describe "state_fu.events" do
        it "should be an array with the only event as its single element" do
          @obj.state_fu.events.should == [@event]
        end
      end

      describe "state_fu.fire!( :transfer )" do
        it "should change the state when called" do
          @obj.state_fu.should respond_to( :fire! )
          @obj.state_fu.state.should == @origin
          @obj.state_fu.fire!( :transfer )
          @obj.state_fu.state.should == @target
        end

        it "should define any methods declared in the .fire! block" do
          trans = @obj.state_fu.fire!( :transfer ) do
            def snoo
              return [self]
            end
          end
          trans.should be_kind_of( StateFu::Transition )
          trans.should respond_to(:snoo)
          trans.snoo.should == [trans]
        end

        it "should return a transition object" do
          @obj.state_fu.fire!( :transfer ).should be_kind_of( StateFu::Transition )
        end

      end # state_fu.fire!

      describe "calling cycle!()" do
        it "should raise an InvalidTransition error" do
          lambda { @obj.state_fu.cycle!() }.should raise_error( StateFu::InvalidTransition )
        end
      end # cycle!

      describe "calling next!()" do
        it "should change the state" do
          @obj.state_fu.state.should == @origin
          @obj.state_fu.next!()
          @obj.state_fu.state.should == @target
        end

        it "should return a transition" do
          trans = @obj.state_fu.next!()
          trans.should be_kind_of( StateFu::Transition )
        end

        it "should define any methods declared in a block given to .transition" do
          trans = @obj.state_fu.next! do
            def snoo
              return [self]
            end
          end
          trans.should be_kind_of( StateFu::Transition )
          trans.should respond_to(:snoo)
          trans.snoo.should == [trans]
        end
      end # next!

      describe "passing args / options to the transition" do
        before do
          @args = [:a, :b, {:c => :d }]
        end

        describe "calling transition( :transfer, nil, :a, :b, :c => :d )" do
          it "should set args to [:a, :b] and options to :c => :d on the transition" do
            t = @obj.state_fu.transition( :transfer, nil, *@args )
            t.args.should    == [ :a, :b ]
            t.options.should == { :c => :d }
          end
        end

        describe "calling fire!( :transfer, nil, :a, :b, :c => :d )" do
          it "should set args to [:a, :b] and options to :c => :d on the transition" do
            t = @obj.state_fu.fire!( :transfer, nil, *@args )
            t.args.should    == [ :a, :b ]
            t.options.should == { :c => :d }
          end
        end

        describe "calling next!( :a, :b, :c => :d )" do
          it "should set args to [:a, :b] and options to :c => :d on the transition" do
            t = @obj.state_fu.next!( *@args )
            t.args.should    == [ :a, :b ]
            t.options.should == { :c => :d }
          end
        end
      end # passing args / options
    end   # binding instance methods
  end     # simple machine w/ 2 states, 1 transition

  #
  #
  #

  describe "A simple machine with 1 state and an event cycling at the same state" do

    before do
      @machine = Klass.machine do
        state :omega do
          event :transfer, :to => :omega
        end
      end
      @state = @machine.states[:omega]
      @event = @machine.events.first
      @obj   = Klass.new
    end

    describe "state_fu instance methods" do
      describe "calling state_fu.cycle!()" do
        it "should not change the state" do
          @obj.state_fu.state.should == @state
          @obj.state_fu.cycle!
          @obj.state_fu.state.should == @state
        end

        it "should pass args / options to the transition" do
          t = @obj.state_fu.cycle!( :a, :b , { :c => :d } )
          t.args.should    == [ :a, :b ]
          t.options.should == { :c => :d }
        end

        it "should not raise an error" do
          @obj.state_fu.cycle!
        end

        it "should return an accepted transition" do
          @obj.state_fu.state.should == @state
          t = @obj.state_fu.cycle!
          t.should be_kind_of( StateFu::Transition )
          t.should be_accepted
        end

      end  # state_fu.cycle!
    end    # state_fu instance methods
  end      # 1 state w/ cyclic event

  #
  #
  #

  describe "A simple machine with 3 states and an event to & from multiple states" do

    before do
      @machine = Klass.machine do
        states :a, :b
        states :x, :y

        event( :go ) do
          from :a, :b
          to   :x, :y
        end

        initial_state :a
      end
      @a = @machine.states[:a]
      @b = @machine.states[:b]
      @x = @machine.states[:x]
      @y = @machine.states[:y]
      @event = @machine.events.first
      @obj   = Klass.new
    end

    it "should have an event from [:a, :b] to [:x, :y]" do
      @event.origin.should == [@a, @b]
      @event.target.should == [@x, @y]
      @obj.state_fu.state.should == @a
    end

    describe "transition instance methods" do
    end

    describe "state_fu instance methods" do
      describe "state_fu.transition" do
        it "should raise an ArgumentError unless a valid target state is supplied" do
          lambda do
            @obj.state_fu.transition( :go )
          end.should raise_error( ArgumentError )

          lambda do
            @obj.state_fu.transition( :go, :awol )
          end.should raise_error( StateFu::InvalidTransition )
        end

        it "should return a transition with the specified target" do
          t = @obj.state_fu.transition( :go, :x )
          t.should be_kind_of( StateFu::Transition )

          lambda do
            @obj.state_fu.transition( :go, :y )
          end.should_not raise_error( )
        end
      end  # state_fu.transition

      describe "state_fu.fire!" do
        it "should raise an ArgumentError unless a valid target state is supplied" do
          lambda do
            @obj.state_fu.fire!( :go )
          end.should raise_error( ArgumentError )

          lambda do
            @obj.state_fu.fire!( :go, :awol )
          end.should raise_error( StateFu::InvalidTransition )
        end
      end # state_fu.fire!

      describe "state_fu.next!" do
        it "should raise an ArgumentError" do
          lambda do
            @obj.state_fu.next!
          end.should raise_error( StateFu::InvalidTransition )
        end
      end # next!

      describe "state_fu.cycle!" do
        it "should raise an ArgumentError" do
          lambda do
            @obj.state_fu.cycle!
          end.should raise_error( StateFu::InvalidTransition )
        end
      end # cycle!

    end    # state_fu instance methods
  end      # 1 state w/ cyclic event

  describe "A simple machine w/ 2 states, 1 event and named hooks " do
    before do
      @machine = Klass.machine do

        state :a do
          on_exit( :exiting_a )
        end

        state :b do
          on_entry( :entering_b )
          accepted( :accepted_b )
        end

        event( :go ) do
          from :a, :to => :b

          before  :before_go
          execute :execute_go
          after   :after_go
        end

        initial_state :a
      end

      @a     = @machine.states[:a]
      @b     = @machine.states[:b]
      @event = @machine.events[:go]
      @obj   = Klass.new
    end # before

    describe "state :a" do
      it "should have a hook for on_exit" do
        @a.hooks[:exit].should == [ :exiting_a ]
      end
    end

    describe "state :b" do
      it "should have a hook for on_entry" do
        @b.hooks[:entry].should == [ :entering_b ]
      end
    end

    describe "event :go" do
      it "should have a hook for before" do
        @event.hooks[:before].should == [ :before_go ]
      end

      it "should have a hook for execute" do
        @event.hooks[:execute].should == [ :execute_go ]
      end

      it "should have a hook for after" do
        @event.hooks[:execute].should == [ :execute_go ]
      end
    end


    describe "a transition for the event" do

      it "should have all defined hooks in correct order of execution" do
        t = @obj.state_fu.transition( :go )
        t.hooks.should be_kind_of( Array )
        t.hooks.should_not be_empty
        t.hooks.should == [ :before_go,
                            :exiting_a,
                            :execute_go,
                            :entering_b,
                            :after_go,
                            :accepted_b ]
      end
    end # a transition ..

    describe "when fired" do
      before do
        @t      = @obj.state_fu.transition( :go )
        stub( @obj ).before_go(@t)  { @called << :before_go  }
        stub( @obj ).exiting_a(@t)  { @called << :exiting_a  }
        stub( @obj ).execute_go(@t) { @called << :execute_go }
        stub( @obj ).entering_b(@t) { @called << :entering_b }
        stub( @obj ).after_go(@t)   { @called << :after_go   }
        stub( @obj ).accepted_b(@t) { @called << :accepted_b }
        @called = []
        [ :before_go,
          :exiting_a,
          :execute_go,
          :entering_b,
          :after_go,
          :accepted_b ]

      end

      it "should call the method for each hook on @obj in order, with the transition" do
        mock( @obj ).before_go(@t)  { @called << :before_go  }
        mock( @obj ).exiting_a(@t)  { @called << :exiting_a  }
        mock( @obj ).execute_go(@t) { @called << :execute_go }
        mock( @obj ).entering_b(@t) { @called << :entering_b }
        mock( @obj ).after_go(@t)   { @called << :after_go   }
        mock( @obj ).accepted_b(@t) { @called << :accepted_b }
        @t.fire!()
        @called.should == [ :before_go,
                            :exiting_a,
                            :execute_go,
                            :entering_b,
                            :after_go,
                            :accepted_b ]

      end

      describe "adding an anonymous hook for event.hooks[:execute]" do
        before do
          called = @called # get us a ref for the closure
          Klass.machine do
            event( :go ) do
              execute do |ctx|
                called << :execute_proc
              end
            end
          end
        end

        it "should be called at the correct point" do
          @event.hooks[:execute].length.should == 2
          @event.hooks[:execute].first.class.should == Symbol
          @event.hooks[:execute].last.class.should  == Proc
          @t.fire!()
          @called.should == [ :before_go,
                              :exiting_a,
                              :execute_go,
                              :execute_proc,
                              :entering_b,
                              :after_go,
                              :accepted_b ]
        end

        it "should be replace the previous proc for a slot if redefined" do
          called = @called # get us a ref for the closure
          Klass.machine do
            event( :go ) do
              execute do |ctx|
                called << :execute_proc_2
              end
            end
          end

          @event.hooks[:execute].length.should == 2
          @event.hooks[:execute].first.class.should == Symbol
          @event.hooks[:execute].last.class.should == Proc

          @t.fire!()
          @called.should == [ :before_go,
                              :exiting_a,
                              :execute_go,
                              :execute_proc_2,
                              :entering_b,
                              :after_go,
                              :accepted_b ]
        end

        describe "halting the transition during the execute hook" do

          before do
            Klass.machine do
              event( :go ) do
                execute do |ctx|
                  ctx.halt!("stop")
                end
              end
            end
          end # before

          it "should prevent the transition from being accepted" do
            @obj.state_fu.state.name.should == :a
            @t.fire!()
            @obj.state_fu.state.name.should == :a
            @t.should be_kind_of( StateFu::Transition )
            @t.should be_halted
            @t.should_not be_accepted
            @called.should == [ :before_go,
                                :exiting_a,
                                :execute_go ]
          end
        end # halting from execute
      end   # anon hook
    end     # when fired

  end # machine w/ hooks

  describe "A simple machine w/ 2 states, 1 event, named & proc hooks" do
    before do
      @machine = Klass.machine do
        state :a do
          on_exit( :exiting_a )
        end

        state :b do
          on_entry( :entering_b )
          accepted( :accepted_b )
        end

        event( :go ) do
          from :a, :to => :b

          before  :before_go
          execute :execute_go
          after   :after_go
        end

        initial_state :a
      end
    end

  end # machine w/ named & proc hooks
end

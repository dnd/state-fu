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
          @obj.state_fu.persister.field_name.should == :state_fu_state
          @obj.send( :state_fu_state ).should == "src"
          @t.fire!
          @obj.send( :state_fu_state ).should == "dest"
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

        it "should have a current_hook && current_hook_slot of nil" do
          @t.current_hook.should == nil
          @t.current_hook_slot.should == nil
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

        it "should raise an error when there is no next state"
        it "should raise an error when there is more than one next state"
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
        state :state_fuega do
          event :transfer, :to => :state_fuega
        end
      end
      @state = @machine.states[:state_fuega]
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
          end.should raise_error( ArgumentError )
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
          end.should raise_error( ArgumentError )
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

    describe "fire! calling hooks" do
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
      end   # anonymous hook

      describe "adding a named hook with a block" do
        describe "with arity of -1/0" do
          it "should call the block in the context of the transition" do
            called = @called # get us a ref for the closure
            Klass.machine do
              event( :go ) do
                execute(:named_execute) do
                  raise self.class.inspect unless self.is_a?( StateFu::Transition )
                  called << :execute_named_proc
                end
              end
            end
            @t.fire!()
            @called.should == [ :before_go,
                                :exiting_a,
                                :execute_go,
                                :execute_named_proc,
                                :entering_b,
                                :after_go,
                                :accepted_b ]
          end
        end # arity 0

        describe "with arity of 1" do
          it "should call the proc in the context of the object, passing the transition as the argument" do
            called = @called # get us a ref for the closure
            Klass.machine do
              event( :go ) do
                execute(:named_execute) do |ctx|
                  raise ctx.class.inspect unless ctx.is_a?( StateFu::Transition )
                  raise self.class.inspect unless self.is_a?( Klass )
                  called << :execute_named_proc
                end
              end
            end
            @t.fire!()
            @called.should == [ :before_go,
                                :exiting_a,
                                :execute_go,
                                :execute_named_proc,
                                :entering_b,
                                :after_go,
                                :accepted_b ]
          end
        end # arity 1
      end   # named proc

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

        it "should have current_hook_slot set to where it halted" do
          @obj.state_fu.state.name.should == :a
          @t.fire!()
          @t.current_hook_slot.should == [:event, :execute]
        end

        it "should have current_hook set to where it halted" do
          @obj.state_fu.state.name.should == :a
          @t.fire!()
          @t.current_hook.should be_kind_of( Proc )
        end

      end # halting from execute
    end   # fire! calling hooks

  end # machine w/ hooks

  describe "A binding for a machine with an event transition requirement" do
    before do
      @machine = Klass.machine do
        event( :go, :from => :a, :to => :b ) do
          requires( :ok? )
        end

        initial_state :a
      end
      @obj = Klass.new
      @binding = @obj.state_fu
      @event = @machine.events[:go]
      @a = @machine.states[:a]
      @b = @machine.states[:b]
    end

    describe "when no block is supplied for the requirement" do

      it "should have an event named :go" do
        @machine.events[:go].requirements.should == [:ok?]
        @machine.events[:go].should be_complete
        @machine.states.map(&:name).sort_by(&:to_s).should == [:a, :b]
        @a.should be_kind_of( StateFu::State )
        @event.should be_kind_of( StateFu::Event )
        @event.origin.map(&:name).should == [:a]
        @binding.current_state.should == @machine.states[:a]
        @event.from?( @machine.states[:a] ).should be_true
        @machine.events[:go].from?( @binding.current_state ).should be_true
        @binding.events.should_not be_empty
      end

      it "should contain :go in @binding.valid_events if evt.fireable_by? is true for the binding" do
        mock( @event ).fireable_by?( @binding ) { true }
        @binding.valid_events.should == [@event]
      end

      it "should contain :go in @binding.valid_events if @binding.evaluate_requirement( :ok? ) is true" do
        mock( @binding ).evaluate_requirement( :ok? ) { true }
        @binding.current_state.should == @machine.initial_state
        @binding.events.should == @machine.events
        @binding.valid_events.should == [@event]
      end

      it "should contain the event in @binding.valid_events if @obj.ok? is true" do
        mock( @obj ).ok? { true }
        @binding.current_state.should == @machine.initial_state
        @binding.events.should == @machine.events
        @binding.valid_events.should == [@event]
      end

      it "should not contain :go in @binding.valid_events if !@obj.ok?" do
        mock( @obj ).ok? { false }
        @binding.events.should == @machine.events
        @binding.valid_events.should == []
      end

      it "should raise a RequirementError if requirements are not satisfied" do
        mock( @obj ).ok? { false }
        lambda do
          @obj.state_fu.fire!( :go )
        end.should raise_error( StateFu::RequirementError )
      end

      it "should have useful info on the error about the failed requirement"

    end # no block

    describe "when a block is supplied for the requirement" do

      it "should be a valid event if the block is true " do
        @machine.named_procs[:ok?] = Proc.new() { true }
        @binding.valid_events.should == [@event]

        @machine.named_procs[:ok?] = Proc.new() { |binding| true }
        @binding.valid_events.should == [@event]

      end

      it "should not be a valid event if the block is false" do
        @machine.named_procs[:ok?] = Proc.new() { false }
        @binding.valid_events.should == []

        @machine.named_procs[:ok?] = Proc.new() { |binding| false }
        @binding.valid_events.should == []
      end

    end # block supplied

  end # machine w/guard conditions


    describe "A binding for a machine with a state transition requirement" do
    before do
      @machine = Klass.machine do
        event( :go, :from => :a, :to => :b )
        state( :b ) do
          requires :entry_ok?
        end
      end
      @obj = Klass.new
      @binding = @obj.state_fu
      @event = @machine.events[:go]
      @a = @machine.states[:a]
      @b = @machine.states[:b]
    end

    describe "when no block is supplied for the requirement" do

      it "should be valid if @binding.valid_transitions' values includes the state" do
        mock( @binding ).valid_transitions{ {@event => [@b] } }
        @binding.valid_next_states.should == [@b]
      end

      it "should be valid if state is enterable_by?( @binding)" do
        mock( @b ).enterable_by?( @binding ) { true }
        @binding.valid_next_states.should == [@b]
      end

      it "should not be valid if state is not enterable_by?( @binding)" do
        mock( @b ).enterable_by?( @binding ) { false }
        @binding.valid_next_states.should == []
      end

      it "should be invalid if @obj.entry_ok? is false" do
        mock( @obj ).entry_ok? { false }
        @b.entry_requirements.should == [:entry_ok?]
        # @binding.evaluate_requirement( :entry_ok? ).should == false
        # @b.enterable_by?( @binding ).should == false
        @binding.valid_next_states.should == []
      end

      it "should be valid if @obj.entry_ok? is true" do
        mock( @obj ).entry_ok? { true }
        @binding.valid_next_states.should == [@b]
      end

    end # no block

    describe "when a block is supplied for the requirement" do

      it "should be a valid event if the block is true " do
        @machine.named_procs[:entry_ok?] = Proc.new() { true }
        @binding.valid_next_states.should == [@b]

        @machine.named_procs[:entry_ok?] = Proc.new() { |binding| true }
        @binding.valid_next_states.should == [@b]
      end

      it "should not be a valid event if the block is false" do
        @machine.named_procs[:entry_ok?] = Proc.new() { false }
        @binding.valid_next_states.should == []

        @machine.named_procs[:entry_ok?] = Proc.new() { |binding| false }
        @binding.valid_next_states.should == []
      end

    end # block supplied
  end # machine with state transition requirement

  describe "a hook method accessing the transition, object, binding and arguments to fire!" do
    before do
      reset!
      make_pristine_class("Klass")
      Klass.machine do
        event(:run, :from => :start, :to => :finish ) do
          execute( :run_exec )
        end
      end # machine
      @obj = Klass.new()
    end # before

    describe "a method defined on the stateful object" do

      it "should have self as the object itself" do
        called = false
        obj    = @obj
        Klass.class_eval do
          define_method( :run_exec ) do |t|
            raise "self is #{self} not #{@obj}" unless self == obj
            called = true
          end
        end
        called.should == false
        trans = @obj.state_fu.fire!(:run)
        called.should == true
      end

      it "should receive a transition and be able to access the binding, etc through it" do
        mock( @obj ).run_exec(is_a(StateFu::Transition)) do |t|
          raise "not a transition" unless t.is_a?( StateFu::Transition )
          raise "no binding" unless t.binding.is_a?( StateFu::Binding )
          raise "no machine" unless t.machine.is_a?( StateFu::Machine )
          raise "no object" unless t.object.is_a?( Klass )
        end
        trans = @obj.state_fu.fire!(:run)
      end

      it "should be able to conditionally execute code based on whether the transition is a test" do
        mock( @obj ).run_exec(is_a(StateFu::Transition)) do |t|
          raise "SHOULD NOT EXECUTE" unless t.testing?
        end
        trans = @obj.state_fu.transition( :run )
        trans.test_only = true
        trans.fire!
        trans.should be_accepted
      end

      it "should be able to call methods on the transition defined in its constructor block" do
        mock( @obj ).run_exec(is_a(StateFu::Transition)) do |t|
          raise "SHOULD NOT EXECUTE" unless t.testing?
        end
        trans = @obj.state_fu.transition( :run )
        trans.test_only = true
        trans.fire!
        trans.should be_accepted
      end

      it "should be able to call methods on the transition mixed in via machine.helper"

      it "should be able to access the arguments passed to fire! via transition.args" do
        args = [:a, :b, { :c => :d }]
        mock( @obj ).run_exec(is_a(StateFu::Transition)) do |t|
          raise "fuck you stan" unless t.args == args
        end
        trans = @obj.state_fu.fire!( :run )
        trans.should be_accepted
      end
    end # method defined on object

    describe "a proc defined in the machine definition" do
    end

  end # args with fire!

end

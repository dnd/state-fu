module StateFu
  class Binding
    include ContextualEval

    attr_reader :object, :machine, :method_name, :persister, :transitions, :options

    def initialize( machine, object, method_name, options={} )
      @machine       = machine
      @object        = object
      @method_name   = method_name
      @transitions   = []
      @options       = options.symbolize_keys!
      field_name     = StateFu::FuSpace.field_names[object.class][@method_name]
      raise( ArgumentError, "No field_name" ) unless field_name
      @persister     = StateFu::Persistence.for( self, field_name )
      Logger.info( "Persister added: #@persister ")

      # define event methods on self( binding ) and @object
      StateFu::MethodFactory.new( self ).install!
    end
    alias_method :o,         :object
    alias_method :obj,       :object
    alias_method :model,     :object
    alias_method :instance,  :object

    alias_method :machine,       :machine
    alias_method :workflow,      :machine
    alias_method :state_machine, :machine

    def field_name
      persister.field_name
    end

    def current_state
      persister.current_state
    end
    alias_method :at,    :current_state
    alias_method :now,   :current_state
    alias_method :state, :current_state

    def current_state_name
      current_state.name
    end
    alias_method :name,       :current_state_name
    alias_method :state_name, :current_state_name
    alias_method :to_sym,     :current_state_name

    # a list of events which can fire from the current_state
    def events
      machine.events.select {|e| e.complete? && e.from?( current_state ) }.extend EventArray
    end
    alias_method :events_from_current_state,  :events

    # the subset of events() whose requirements for firing are met
    def valid_events
      return [] unless current_state.exitable_by?( self )
      events.select {|e| e.fireable_by?( self ) }.extend EventArray
    end

    def invalid_events
      (events - valid_events).extend StateArray
    end

    def unmet_requirements_for(event, target)
      raise NotImplementedError
    end

    # the counterpart to valid_events - the states we can arrive at in
    # the firing of one event, taking into account event and state
    # transition requirements
    def valid_next_states
      valid_transitions.values.flatten.uniq.extend StateArray
    end

    def next_states
      events.map(&:targets).compact.flatten.uniq.extend StateArray
    end

    def invalid_next_states
      states - valid_states
    end

    # returns a hash of { event => [states] } whose transition
    # requirements are met
    def valid_transitions
      h = {}
      valid_events.each do |e|
        h[e] = e.targets.select do |s|
          s.enterable_by?( self )
        end
      end
      h
    end

    # initialize a new transition
    def transition( event_or_array, *args, &block )
      event, target = parse_destination( event_or_array )
      StateFu::Transition.new( self, event, target, *args, &block )
    end
    alias_method :fire,    :transition
    alias_method :trigger, :transition

    # sanitize args for fire! and fireable?
    def parse_destination( event_or_array )
      case event_or_array
      when StateFu::Event, Symbol
        event  = event_or_array
        target = nil
      when Array
        event, target = event_or_array
      end
      raise ArgumentError.new( event_or_array.inspect ) unless
        [StateFu::Event, Symbol  ].include?( event.class  ) &&
        [StateFu::State, Symbol, NilClass].include?( target.class )
      [event, target]
    end

    # check that the event and target are "valid" (all requirements met)
    def fireable?( event_or_array )
      event, target = parse_destination( event_or_array )
      t = transition( [event, target] )
      !! t.requirements_met?
    end
    alias_method :event?,         :fireable?
    alias_method :trigger?,       :fireable?
    alias_method :triggerable?,   :fireable?
    alias_method :transition?,    :fireable?
    alias_method :transitionable?,:fireable?

    # construct an event transition and fire it
    def fire!( event_or_array, *args, &block)
      event, target = parse_destination( event_or_array )
      t = transition( [event, target], *args, &block )
      t.fire!
      t
    end
    alias_method :event!,    :fire!
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # evaluate a requirement depending whether it's a method or proc,
    # and its arity - see helper.rb (ContextualEval) for the smarts
    def evaluate_requirement( name )
      evaluate_named_proc_or_method( name )
    end

    def evaluate_requirement_message( name, dest )
      msg = machine.requirement_messages[name]
      if [String, NilClass].include?( msg.class )
        return msg
      else
        if dest.is_a?( StateFu::Transition )
          t = dest
        else
          event, target = parse_destination( event_or_array )
          t = transition( event, target )
        end
        case msg
        when Symbol
          t.evaluate_named_proc_or_method( msg )
        when Proc
          t.evaluate &msg
        end
      end
    end

    # if there is one simple event, return a transition for it
    # else return nil
    # TODO - not convinced about the method name / aliases - but next
    # is reserved :/
    def next_transition( *args, &block )
      if events.select(&:simple?).length == 1
        transition( events.select(&:simple?)[0], *args, &block )
      end
    end
    alias_method :next_state, :next_transition
    alias_method :next_event, :next_transition

    # if there is a next_transition, create, fire & return it
    # otherwise raise an InvalidTransition
    def next!( *args, &block )
      if t = next_transition( *args, &block )
        t.fire!
        t
      else
        n = events.select(&:simple?).length
        raise InvalidTransition.
          new( self, current_state, events.select(&:simple?),
               "there are #{n} candidate next events, need exactly 1")
      end
    end
    alias_method :next_state!, :next!
    alias_method :next_event!, :next!

    # if there is a next_transition, return true / false depending on
    # whether its requirements are met
    # otherwise, nil
    def next?( *args, &block )
      if t = next_transition( *args, &block )
        t.requirements_met?
      end
    end
    alias_method :next_state?, :next?
    alias_method :next_event?, :next?

    # if there is one possible cyclical event, return a transition there
    def cycle( *args, &block)
      cycle_events = events.select {|e| e.target == current_state }
      if cycle_events.length == 1
        transition( cycle_events[0], *args, &block )
      end
    end

    # if there is a cycle() transition, fire and return it
    # otherwise raise an InvalidTransition
    def cycle!( *args, &block )
      if t = cycle( *args, &block )
        t.fire!
        t
      else
        err_msg = "Cannot cycle! unless there is exactly one event leading from the current state to itself"
        raise InvalidTransition.new( self, current_state, current_state, err_msg )
      end
    end

    # if there is one possible cyclical event, evaluate its
    # requirements (true/false), else nil
    def cycle?
      if t = cycle
        t.requirements_met?
      end
    end

    # display something sensible that doesn't take up the whole screen
    def inspect
      "#<#{self.class} ##{__id__} object_type=#{@object.class} method_name=#{method_name.inspect} field_name=#{persister.field_name.inspect} machine=#{@machine.inspect} options=#{options.inspect}>"
    end

  end
end

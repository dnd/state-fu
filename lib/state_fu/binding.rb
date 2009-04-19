module StateFu
  class Binding

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
    alias_method :state, :current_state

    # a list of events which can fire from the current_state
    def events
      machine.events.select {|e| e.complete? && e.from?( current_state ) }.extend ArrayWithSymbolAccessor
    end
    alias_method :events_from_current_state,  :events

    # the subset of events() whose requirements for firing are met
    def valid_events
      return [] unless current_state.exitable_by?( self )
      events.select {|e| e.fireable_by?( self ) }.extend ArrayWithSymbolAccessor
    end

    def invalid_events
      events - valid_events
    end

    def unmet_requirements_for(event, target)
      raise NotImplementedError
    end

    # the counterpart to valid_events - the states we can arrive at in
    # the firing of one event, taking into account event and state
    # transition requirements
    def valid_next_states
      valid_transitions.values.flatten.uniq.extend ArrayWithSymbolAccessor
    end

    def next_states
      raise NotImplementedError
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
    def transition( event, target=nil, *args, &block )
      StateFu::Transition.new( self, event, target, *args, &block )
    end

    def transition( event_or_array, *args, &block )
      event, target = parse_destination( event_or_array )
      StateFu::Transition.new( self, event, target, *args, &block )
    end

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

    # construct an event transition and fire it
    def fire!( event_or_array, *args, &block)
      event, target = parse_destination( event_or_array )
      t = transition( [event, target], *args, &block )
      t.fire!
      t
    end
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # pretty similar to transition.run_hook - evaluate a requirement
    # depending whether it's a method or proc, and its arity
    def evaluate_requirement( name )
      if proc = machine.named_procs[name]
        if proc.arity == 1
          object.instance_exec( self, &proc )
        else
          instance_eval( &proc )
        end
      else
        object.send( name )
      end
    end

    # TODO - give better errors on failed requirements
    def evaluate_requirement!( name )
      evaluate_requirement( name ) || raise( RequirementError )
    end

    # fire event to move to the next state, if there is only one possible state.
    # otherwise raise an error ( InvalidTransition )
    # TODO - make a 'soft' version of this which returns a transition
    # or false
    def next!( *args, &block )
      next_events = events.select {|e| e.target }
      case next_events.length
      when 0
        err_msg = "There is no event for next!"
        raise StateFu::InvalidTransition.new( self,
                                              current_state,
                                              nil,
                                              err_msg )
      when 1
        event = next_events.first
        fire!( event, *args, &block )
      else
        err_msg = "There is more than one candidate event for next!"
        raise StateFu::InvalidTransition.new( self,
                                              current_state,
                                              next_events,
                                              err_msg )
      end
    end
    alias_method :next_state!, :next!

    # fire an event to & from the current state, or raise InvalidTransition
    # TODO - make a 'soft' version of this which returns a transition
    # or false
    def cycle!( *args, &block )
      cycle_events = events.select {|e| e.target == current_state }
      if cycle_events.length == 1
        event = cycle_events.first
        fire!( event, *args, &block )
      else
        err_msg = "Cannot cycle! unless there is exactly one event leading from the current state to itself"
        raise StateFu::InvalidTransition.new( self,
                                              current_state,
                                              current_state,
                                              err_msg )
      end
    end
    alias_method :call!,       :fire!
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # display sensibly
    def inspect
      "#<#{self.class} ##{__id__} object_type=#{@object.class} method_name=#{method_name.inspect} field_name=#{persister.field_name.inspect} machine=#{@machine.inspect} options=#{options.inspect}>"
    end

  end
end

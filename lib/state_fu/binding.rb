module StateFu
  class Binding

    attr_reader :object, :machine, :method_name, :persister, :transitions

    def initialize( machine, object, method_name )
      @machine       = machine
      @object        = object
      @method_name   = method_name
      @transitions   = []
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

    def events
      machine.events.select {|e| e.complete? && e.from?( current_state ) }.extend ArrayWithSymbolAccessor
    end
    alias_method :events_from_current_state,  :events

    def valid_events
      events.select {|e| e.fireable_by?( self ) }.extend ArrayWithSymbolAccessor
    end

    def unmet_requirements_for(event, target)
      raise NotImplementedError
    end

    def valid_next_states
      valid_transitions.values.flatten.uniq.extend ArrayWithSymbolAccessor
    end

    # returns a hash of valid { event_name => [state, state ..] }
    def valid_transitions
      h = {}
      valid_events.each do |e|
        h[e] = e.target.select do |s|
          s.enterable_by?( self )
        end
      end
      h
    end

    # initialize a new transition
    def transition( event, target=nil, *args, &block )
      StateFu::Transition.new( self, event, target, *args, &block )
    end

    # sanitize args for fire! and fireable?
    def event_or_array_to_array_of_event_and_target( event_or_array )
      case event_or_array
      when StateFu::Event, Symbol
        event  = event_or_array
        target = nil
      when Array
        event, target = event_or_array
      end
      raise ArgumentError.new( event_or_array.inspect ) unless
        [StateFu::Event, Symbol  ].include?( event.class  ) &&
        [StateFu::State, NilClass].include?( target.class )
      [event,target]
    end

    # check that the event and target are valid
    def fireable?( event_or_array )
      event, target = event_or_array_to_array_of_event_and_target( event_or_array )
      t = transition( event, target )
      !!t.valid?
    end

    # fire event
    def fire!( event_or_array, *args, &block)
      event, target = event_or_array_to_array_of_event_and_target( event_or_array )
      t = transition( event, target, *args, &block )
      t.fire!
      t
    end
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # pretty similar to transition.run_hook
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
    # otherwise raise an error ( NoNextStateError)
    def next!( *args, &block )
      next_events = events.select {|e| e.target.length == 1 }
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

    def cycle!( *args, &block )
      cycle_events = events.select {|e| e.target == [current_state] }
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

    def inspect
      "<#{self.class} #{hash} object=#{@object} machine=#{@machine}>"
    end

  end
end

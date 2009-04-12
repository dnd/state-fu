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
      machine.events.select {|e| e.complete? && e.from?( current_state ) }
    end
    alias_method :events_from_current_state,  :events

    def transition( event, target=nil, options={}, &block )
      StateFu::Transition.new( self, event, target, options, &block )
    end

    # fire event
    def fire!( event, target=nil, options={}, &block)
      t = transition( event, target, options, &block )
      t.fire!
      t
    end
    alias_method :call!,       :fire!
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # fire event to move to the next state, if there is only one possible state.
    # otherwise raise an error ( NoNextStateError)
    def next!( options={}, &block )
      next_events = events.select {|e| e.target.length == 1 }
      case next_events.length
      when 0
        err_msg = "There is no event for next!"
        raise StateFu::InvalidTransition.new( self,
                                              current_state,
                                              nil,
                                              err_msg )
      when 1
        fire!( next_events.first, nil, options, &block )
      else
        err_msg = "There is more than one candidate event for next!"
        raise StateFu::InvalidTransition.new( self,
                                              current_state,
                                              next_events,
                                              err_msg )
      end
    end
    alias_method :next_state!, :next!

    def cycle!( options={}, &block )
      cycle_events = events.select {|e| e.target == [current_state] }
      if cycle_events.length == 1
        event = cycle_events.first
        fire!( event )
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

  end
end

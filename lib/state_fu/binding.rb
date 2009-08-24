module StateFu
  class Binding

    attr_reader :object, :machine, :method_name, :field_name, :persister, :transitions, :options, :target


    # the constructor should not be called manually; a binding is
    # returned when an instance of a class with a StateFu::Machine
    # calls:
    #
    # instance.#state_fu (for the default machine which is called :state_fu),
    # instance.#state_fu( :<machine_name> ) ,or
    # instance.#<machine_name>
    #
    def initialize( machine, object, method_name, options={} )
      @machine       = machine
      @object        = object
      @method_name   = method_name
      @transitions   = []
      @options       = options.symbolize_keys!
      @target        = singleton? ? object : object.class
      @field_name    = options[:field_name] || @target.state_fu_field_names[method_name]
      @persister     = Persistence.for( self )

      # define event methods on this binding and its @object
      MethodFactory.new( self ).install!
      @machine.helpers.inject_into( self )
    end

    alias_method :o,         :object
    alias_method :obj,       :object
    alias_method :model,     :object
    alias_method :instance,  :object

    alias_method :workflow,      :machine
    alias_method :state_machine, :machine

    #
    # current state
    #

    # the current State
    def current_state
      persister.current_state
    end
    alias_method :now,   :current_state
    alias_method :state, :current_state

    # the name, as a Symbol, of the binding's current_state
    def current_state_name
      begin
        current_state.name.to_sym
      rescue NoMethodError
        nil
      end
    end
    alias_method :name,       :current_state_name
    alias_method :state_name, :current_state_name
    alias_method :to_sym,     :current_state_name

    #
    # events
    #

    # returns a list of Events which can fire from the current_state
    def events
      machine.events.select do |e|
        e.can_transition_from? current_state
      end.extend EventArray
    end
    alias_method :events_from_current_state,  :events

    # the subset of events() whose requirements for firing are NOT met
    # (with the arguments supplied, if any)
    def invalid_events( *args )
      ( events - valid_events( *args ) ).extend StateArray
    end

    #
    # transition validation
    #

    def transitions(opts={}) # .with(*args)
      TransitionQuery.new(self, opts)
    end

    def valid_transitions(*args)
      transitions.valid.with(*args)
    end

    def valid_next_states(*args)
      transitions.with(*args).targets
    end

    def valid_events(*args)
      transitions.with(*args).events
    end

    # all states which can be reached from the current_state. Does not check transition requirements, etc.
    def next_states
      events.map(&:targets).compact.flatten.uniq.extend StateArray
    end

    #
    # transition constructor
    #

    def new_transition(event, target, *args, &block)
      Transition.new( self, event, target, *args, &block )
    end
    
    # initializes a new Transition to the given destination, with the
    # given *args (to be passed to requirements and hooks).
    #
    # If a block is given, it yields the Transition or is executed in
    # its evaluation context, depending on the arity of the block.
    def transition( event_or_array, *args, &block )
      # raise args.inspect
      return transitions.with(*args, &block).find(event_or_array)
      
      # returning transitions.find(event_or_array) do |t|
      #   if t
      #     t.apply!(&block) if block_given?
      #     t.args = args
      #   end
      # end
      # Transition.new( self, event, target, *args, &block )
    end
    alias_method :fire,             :transition
    alias_method :fire_event,       :transition
    alias_method :trigger,          :transition
    alias_method :trigger_event,    :transition
    alias_method :begin_transition, :transition

    # check that the event and target are valid (all requirements are
    # met) with the given (optional) arguments
    def fireable?( event_or_array, *args )
      begin
        return nil unless t = transition( event_or_array, *args )
        !! t.requirements_met?
      rescue InvalidTransition => e
        nil
      end
    end

    # construct an event transition and fire it, returning the transition.
    # (which is == true if the transition completed successfully.)
    def fire!( event_or_array, *args, &block)
      # special case - complex event with no target supplied, but only one is possible
      # TODO / FIXME rather than testing next_transition, check that only one target is valid for this event.

      # rather than die, try to find the next valid transition and fire that
      if event_or_array.is_a?(Array) && event_or_array[1] == nil && t = next_transition(*args) 
        t = nil unless t.origin == current_state
      end

      if t
        t.apply!(&block) if block_given?
      else
        t = transition( event_or_array, *args, &block )
      end

      t = transition(event_or_array, *args, &block )
      t.fire!
      t
    end
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!


    #
    # next_transition and friends: when there's exactly one valid move
    #
    
    # if there is exactly one legal transition which can be fired with
    # the given (optional) arguments, return it.
    def next_transition( *args, &block )
      transitions.with(*args, &block).next
    end

    def next_transition_excluding_cycles( *args, &block )
      transitions.not_cyclic.with(*args, &block).next
    end

    # if there is exactly one state reachable via a transition which
    # is valid with the given optional arguments, return it.
    def next_state( *args )
      nt = next_transition_excluding_cycles( *args )
      nt && nt.target # || nil
    end

    # if there is exactly one event which is valid with the given
    # optional arguments, return it
    def next_event( *args )
      nt = next_transition_excluding_cycles( *args )
      nt && nt.event
    end
    
    #
    # refactor move these blocks of code into TransitionQuery
    #

    # if there is a next_transition, create, fire & return it
    # otherwise raise an InvalidTransition
    def next!( *args, &block )
      opts = {}
      opts = args.last.symbolize_keys if args.last.is_a?(Hash)
      if opts[:cyclic] == true
        t = next_transition( *args, &block )
      else
        t = next_transition_excluding_cycles( *args, &block )
      end
      if t
        t.fire!
        t
      else
        vts             = valid_transitions( *args )
        vt_destinations = vts.map {|t| [t.event.name, t.target.name]}
        raise TransitionNotFound.new( self, "there are #{vts.length} candidate transitions, need exactly 1 :: #{vt_destinations.inspect}", :valid_transitions => vts)
      end
    end
    alias_method :next_transition!, :next!
    alias_method :next_event!, :next!
    alias_method :next_state!, :next!

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

    #
    # Cyclic transitions (origin == target)
    #

    # if there is one possible cyclical event, return a transition there
    # otherwise, maybe we got an event name as an argument?
    def cycle( *args, &block)
      cycle_events = events.select {|e| e.target == current_state }
      case cycle_events.length
      when 1
        transition( cycle_events[0], *args, &block )
      when 0
      else
        if [[Symbol], [String]].include?(args.map(&:class)) && evt = cycle_events.detect {|e| e.name == (args[0].to_sym) }
          transition( evt, *args, &block )
        else
          # valid_transitions :cycle => true
        end
      end
    end

    # if there is a single possible cycle() transition, fire and return it
    # otherwise raise an InvalidTransition
    def cycle!( *args, &block )
      if t = cycle( *args, &block )
        t.fire!
        t
      else
        raise TransitionNotFound.new( self, "Cannot cycle! unless there is exactly one event leading from the current state to itself")
      end
    end

    # if there is one possible cyclical event, evaluate its
    # requirements (true/false), else nil
    def cycle?( *args )
      if t = cycle( *args )
        t.requirements_met?
      end
    end

    #
    # misc
    #

    # change the current state of the binding without any
    # requirements or other sanity checks, or any hooks firing.
    # Useful for test / spec scenarios, and abusing the framework.
    def teleport!( target )
      persister.current_state=( machine.states[target] )
    end

    # TODO better name
    # is this a binding unique to a specific instance (not bound to a class)?
    def singleton?
      options[:singleton]
    end

    # SPECME DOCME OR KILLME 
    def reload()
      if persister.is_a?( Persistence::ActiveRecord )
        object.reload
      end
      persister.reload
      self
    end

    # display something sensible that doesn't take up the whole screen
    def inspect
      '|<= ' + self.class.to_s + ' ' +
        attrs = [[:current_state, state_name.inspect],
                 [:object_type , @object.class],
                 [:method_name , method_name.inspect],
                 [:field_name  , field_name.inspect],
                 [:machine     , machine.inspect]].
        map {|x| x.join('=') }.join( " " ) + ' =>|'
    end

    # let's be == (and hence ===) the current_state_name as a symbol.
    # a nice little convenience.
    def == other
      if other.respond_to?( :to_sym ) && current_state
        current_state_name == other.to_sym || super( other )
      else
        super( other )
      end
    end

    # This method is called from methods defined by MethodFactory. 
    # You don't want to call it directly.
    def _event_method(action, event, *args)
      target_or_options = args.shift
      options           = {}
      case target_or_options
      when Hash
        options = target_or_options.symbolize_keys!
        target  = target_or_options.delete[:to]
      when Symbol, String
        target  = target_or_options.to_sym
      when nil
        target  = nil
      end

      case action
      when :get_transition
        transition [event, target], *args, &lambda {|t| t.options = options}
      when :query_transition
        fireable?  [event, target], *args, &lambda {|t| t.options = options}
      when :fire_transition
        fire!      [event, target], *args, &lambda {|t| t.options = options}
      else
        raise ArgumentError.new(action)
      end
    end

  end
end

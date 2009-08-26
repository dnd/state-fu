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

    alias_method :o,             :object
    alias_method :obj,           :object
    alias_method :model,         :object
    alias_method :instance,      :object

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

    # all states which can be reached from the current_state. 
    # Does not check transition requirements, etc.
    def next_states
      events.map(&:targets).compact.flatten.uniq.extend StateArray
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
      valid_transitions(*args).targets
    end

    def valid_events(*args)
      valid_transitions(*args).events
    end
    
    def invalid_events(*args)
      (events - valid_events(*args)).extend StateArray
    end
    

    # initializes a new Transition to the given destination, with the
    # given *args (to be passed to requirements and hooks).
    #
    # If a block is given, it yields the Transition or is executed in
    # its evaluation context, depending on the arity of the block.
    def transition( event_or_array, *args, &block )
      return transitions.with(*args, &block).find(event_or_array)
    end
    # alias_method :firing,           :transition
    # alias_method :trigger,          :transition
    # alias_method :fire_event,       :transition
    # alias_method :trigger_event,    :transition
    # alias_method :begin_transition, :transition

    # check that the event and target are valid (all requirements are
    # met) with the given (optional) arguments
    # def fireable?(destination, *args )
    #     event, target = destination
    #   begin
    #     return nil unless t = transition( destination, *args )
    #     !! t.requirements_met?
    #   rescue IllegalTransition => e
    #     nil
    #   end
    # end
    #     
    # def fireable(event, target=nil)
    #   t = transition([event, target]) rescue nil ||  NilTransition.new 
    # end
    # 
    # def fireable_with?(event, target=nil) 
    #   begin
    #     return NilTransition.new unless t = transition([event, target])
    #     !! t.requirements_met?
    #   rescue IllegalTransition => e
    #     nil
    #   end
    # end

    # construct an event transition and fire it, returning the transition.
    # (which is == true if the transition completed successfully.)
    # def fire!(destination)
    #   event, target = destination
    #   transition([event, target]).fire!
    # end
    # alias_method :trigger!,    :fire!
    # alias_method :transition!, :fire!

    #
    # next_transition and friends: when there's exactly one valid move
    #
    
    # if there is exactly one legal & valid transition which can be fired with
    # the given (optional) arguments, return it.
    def next_transition( *args, &block )
      transitions.with(*args, &block).next
    end
    
    # as above but ignoring any transitions whose origin and target are the same
    def next_transition_excluding_cycles( *args, &block )
      transitions.not_cyclic.with(*args, &block).next
    end

    # if there is exactly one state reachable via a transition which
    # is valid with the given optional arguments, return it.
    def next_state(*args, &block)
      transitions.with(*args, &block).next_state 
    end

    # if there is exactly one event which is valid with the given
    # optional arguments, return it
    def next_event( *args )
      transitions.with(*args, &block).next_event
    end
    
    # if there is a next_transition, create, fire & return it
    # otherwise raise an IllegalTransition
    def next!( *args, &block )
      if t = next_transition( *args, &block )
        t.fire!
      else
        raise TransitionNotFound.new( self, valid_transitions(*args), "Exactly 1 valid transition required.")
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
    # alias_method :next_state?, :next?
    # alias_method :next_event?, :next?

    # Cyclic transitions (origin == target)

    # if there is one possible cyclical event, return a transition there
    # otherwise, maybe we got an event name as an argument?
    def cycle(event_or_array=nil, *args, &block)
      if event_or_array.nil?
        transitions.cyclic.with(*args, &block).singular ||
          transitions.cyclic.with(*args, &block).valid.singular
      else
        transitions.cyclic.with(*args, &block).find(event_or_array)
      end
    end

    # if there is a single possible cycle() transition, fire and return it
    # otherwise raise an IllegalTransition
    def cycle!(event_or_array=nil, *args, &block )
      if t = cycle(event_or_array, *args, &block )
        t.fire!
        t
      else
        raise TransitionNotFound.new( self, transitions.cyclic.with(*args,&block), "Cannot cycle! unless there is exactly one cyclic event")
      end
    end

    # if there is one possible cyclical event, evaluate its
    # requirements (true/false), else nil
    def cycle?(event_or_array=nil, *args )
      if t = cycle(event_or_array, *args )
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

    def inspect
      s = self.to_s
      s = s[0,s.length-1]
      s << " object=#{object.class} of #{object}" 
      s << " current_state=#{current_state.to_sym rescue nil}" 
      s << " events=#{events.map(&:to_sym).inspect rescue nil}" 
      s << " machine=#{machine.inspect}" 
      s << ">"
      s
    end

    #
    # These methods are called from methods defined by MethodFactory. 
    # You pobably don't want to call them directly.
    #

    # event_name 
    def find_transition(event, target=nil, *args)
      target ||= args.last[:to].to_sym rescue nil      
      query = transitions.for_event(event).to(target).with(*args)
      query.find || query.valid.singular || NilTransition.new      
      # transition = binding.transitions.with(*args).search([event, target])
    end

    # event_name?
    def can_transition?(event, target=nil, *args)
      begin
        if t = find_transition(event, target, *args) 
          t.valid?(*args)
        end
      rescue IllegalTransition, UnknownTarget
        nil
      end      
    end

    # event_name!
    def fire_transition!(event, target=nil, *args)
      find_transition(event, target, *args).fire! *args
    end

    #
    # transition constructor
    #
    def new_transition(event, target, *args, &block)
      Transition.new( self, event, target, *args, &block )
    end
  end
end

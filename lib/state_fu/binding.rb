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
      # ensure state field is set up (in case we created this binding
      # manually, instead of via Machine.bind!)
      StateFu::Persistence.prepare_field( object.class, field_name )
      # add a persister
      @persister     = StateFu::Persistence.for( self, field_name )
      Logger.info( "Persister (#{@persister.class}) added: #{method_name} as field #{field_name}" )

      # define event methods on self( binding ) and @object
      StateFu::MethodFactory.new( self ).install!
      machine.helpers.inject_into( self )
      # StateFu::Persistence.prepare_field( @object.class, field_name )
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
      begin
        current_state.name.to_sym
      rescue NoMethodError
        nil
      end
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
    def valid_events( *args )
      return nil unless current_state
      return [] unless current_state.exitable_by?( self, *args )
      events.select {|e| e.fireable_by?( self, *args ) }.extend EventArray
    end

    def invalid_events( *args )
      ( events - valid_events( *args ) ).extend StateArray
    end

    def unmet_requirements_for( event, target )
      raise NotImplementedError
    end

    # the counterpart to valid_events - the states we can arrive at in
    # the firing of one event, taking into account event and state
    # transition requirements
    def valid_next_states( *args )
      vt = valid_transitions( *args )
      vt && vt.values.flatten.uniq.extend( StateArray )
    end

    def next_states
      events.map(&:targets).compact.flatten.uniq.extend StateArray
    end

    # returns a hash of { event => [states] } whose transition
    # requirements are met
    def valid_transitions( *args )
      h  = {}
      return nil unless ve = valid_events( *args )
      ve.each do |e|
        h[e] = e.targets.select do |s|
          s.enterable_by?( self, *args )
        end
      end
      h
    end

    # initialize a new transition
    def transition( event_or_array, *args, &block )
      event, target = parse_destination( event_or_array )
      StateFu::Transition.new( self, event, target, *args, &block )
    end
    alias_method :fire,             :transition
    alias_method :fire_event,       :transition
    alias_method :trigger,          :transition
    alias_method :trigger_event,    :transition
    alias_method :begin_transition, :transition

    def blank_mock_transition( *args, &block )
      StateFu::MockTransition.new( self, nil, nil, *args, &block )
    end

    def mock_transition( event_or_array, *args, &block )
      event, target = nil
      event, target = parse_destination( event_or_array )
      StateFu::MockTransition.new( self, event, target, *args, &block )
    end

    # sanitize args for fire! and fireable?
    def parse_destination( event_or_array )
      case event_or_array
      when StateFu::Event, Symbol
        event  = event_or_array
        target = nil
      when Array
        event, target = *event_or_array
      end
      x = event_or_array.is_a?( Array ) ? event_or_array.map(&:class) : event_or_array
      raise ArgumentError.new( x.inspect ) unless
        [StateFu::Event, Symbol  ].include?( event.class  ) &&
        [StateFu::State, Symbol, NilClass].include?( target.class )
      [event, target]
    end

    # check that the event and target are "valid" (all requirements met)
    def fireable?( event_or_array, *args )
      event, target = parse_destination( event_or_array )
      begin
        t = transition( [event, target] )
        !! t.requirements_met?
      rescue InvalidTransition => e
        nil
      end
    end
    alias_method :event?,             :fireable?
    alias_method :event_fireable?,    :fireable?
    alias_method :can_fire?,          :fireable?
    alias_method :can_fire_event?,    :fireable?
    alias_method :trigger?,           :fireable?
    alias_method :triggerable?,       :fireable?
    alias_method :can_trigger?,       :fireable?
    alias_method :can_trigger_event?, :fireable?
    alias_method :event_triggerable?, :fireable?
    alias_method :transition?,        :fireable?
    alias_method :can_transition?,    :fireable?
    alias_method :transitionable?,    :fireable?

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

    # TODO - enable requirement block / method to know the target

    def evaluate_requirement_with_args( name, *args )
      t = blank_mock_transition( *args )
      evaluate_named_proc_or_method( name, t )
    end
    # alias_method :evaluate_requirement, :evaluate_requirement_with_args

    alias_method :evaluate_requirement_with_transition, :evaluate_named_proc_or_method

    # TODO SPECME HACKERY CRUFT FIXME THISSUCKS and needs *args
    # def evaluate_requirement_message( name, dest )
    #   # puts "#{name} #{dest}"
    #   msg = machine.requirement_messages[name]
    #   if [String, NilClass].include?( msg.class )
    #     return msg
    #   else
    #     if dest.is_a?( StateFu::Transition )
    #       t = dest
    #     else
    #       event, target = parse_destination( event_or_array )
    #       t = transition( event, target )
    #     end
    #     case msg
    #     when Symbol, Proc
    #       puts t.class
    #       evaluate_named_proc_or_method( msg, t )
    #     # when Proc
    #     #   t.evaluate &msg
    #     end
    #   end
    # end

    # if there is one simple event, return a transition for it
    # else return nil
    # TODO - not convinced about the method name / aliases - but next
    # is reserved :/
    def next_transition( *args, &block )
      vts = valid_transitions( *args )
      return nil if vts.nil?
      next_transition_candidates = vts.select {|e, s| s.length == 1 }
      if next_transition_candidates.length == 1
        nt   = next_transition_candidates.first
        evt  = nt[0]
        targ = nt[1][0]
        return transition( [ evt, targ], *args, &block )
      end
    end

    def next_state( *args )
      nt = next_transition( *args )
      nt && nt.target
    end

    def next_event( *args )
      nt = next_transition( *args )
      nt && nt.event
    end

    # if there is a next_transition, create, fire & return it
    # otherwise raise an InvalidTransition
    def next!( *args, &block )
      if t = next_transition( *args, &block )
        t.fire!
        t
      else
        vts = valid_transitions( *args )
        n = vts && vts.length
        raise InvalidTransition.
          new( self, current_state, vts, "there are #{n} candidate transitions, need exactly 1")
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
    def cycle?( *args )
      if t = cycle( *args )
        t.requirements_met?
      end
    end

    def teleport!( target )
      persister.current_state=( machine.states[target] )
    end

    # display something sensible that doesn't take up the whole screen
    def inspect
      '|<= ' + self.class.to_s + ' ' +
        attrs = [[:current_state, state_name.inspect],
                 [:object_type , @object.class],
                 [:method_name , method_name.inspect],
                 [:field_name  , persister.field_name.inspect],
                 [:machine     , machine.inspect]].
        map {|x| x.join('=') }.join( " " ) + ' =>|'
    end

    def == other
      if other.respond_to?(:to_sym) && current_state_name.is_a?(Symbol)
        other.to_sym == current_state_name || super( other )
      else
        super( other )
      end
    end

  end
end

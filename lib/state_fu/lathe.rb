module StateFu
  # A Lathe parses and a Machine definition and returns a freshly turned
  # Machine.
  #
  # It provides the means to define the arrangement of StateFu objects
  # ( eg States and Events) which comprise a workflow, process,
  # lifecycle, circuit, syntax, etc.
  class Lathe

    # NOTE: Sprocket is the abstract superclass of Event and State
    # @sprocket can be either nil (the main Lathe for a Machine)
    # or contain a State or Event (a child lathe for a nested block)

    attr_reader :machine, :sprocket, :options

    # you don't need to call this directly.
    def initialize( machine, sprocket = nil, options={}, &block )
      @machine  = machine
      @sprocket = sprocket
      @options  = options.symbolize_keys!

      # extend ourself with any previously defined tools
      machine.tools.inject_into( self )

      if sprocket
        sprocket.apply!( options )
      end
      if block_given?
        if block.arity == 1
          if sprocket
            yield sprocket
          else
            raise ArgumentError
          end
        else
          instance_eval( &block )
        end
      end
    end

    #
    # utility methods
    #

    # a 'child' lathe is created by apply_to, to deal with nested
    # blocks for states / events ( which are sprockets )
    def child?
      !!@sprocket
    end

    # is this the toplevel lathe for a machine?
    def master?
      !child?
    end

    # get the top level Lathe for the machine
    def master_lathe
      machine.lathe
    end

    #
    # methods for extending the DSL
    #

    # helpers are mixed into all binding / transition contexts
    def helper( *modules )
      machine.helper *modules
    end

    # helpers are mixed into all binding / transition contexts
    def tool( *modules )
      machine.tool *modules
      # inject them into self for immediate use
      modules.flatten.extend( ToolArray ).inject_into( self )
    end

    #
    # event definition methods
    #

    # Defines an event. Any options supplied will be added to the event,
    # except :from and :to which are used to define the origin / target
    # states. Successive invocations will _update_ (not replace) previously
    # defined events; origin / target states and options are always
    # accumulated, not clobbered.
    #
    # Several different styles of definition are available. Consult the
    # specs / features for examples.
  
    def event( name, options={}, &block )
      options.symbolize_keys!
      require_sprocket( StateFu::State, NilClass )
      if child? && sprocket.is_a?( StateFu::State ) # in state block
        targets  = options.delete(:to)
        evt      = define_event( name, options, &block )
        evt.from sprocket unless sprocket.nil?
        evt.to( targets ) unless targets.nil?
        evt
      else # in master lathe
        origins = options.delete( :from )
        targets = options.delete( :to )
        evt     = define_event( name, options, &block )
        evt.from origins unless origins.nil?
        evt.to   targets unless targets.nil?
        evt
      end
    end

    # define an event or state requirement.
    # options:
    #  :on => :entry|:exit|array (state only) - check requirement on state entry, exit or both? 
    #     default = :entry
    #  :message => string|proc|proc_name_symbol - message to be returned on requirement failure.
    #     if a proc or symbol (named proc identifier), evaluated at runtime; a proc should 
    #     take one argument, which is a StateFu::Transition.
    #  :msg => alias for :message, for the morbidly terse
    
    def requires( *args, &block )
      require_sprocket( StateFu::Event, StateFu::State )
      options = args.extract_options!.symbolize_keys!
      options.assert_valid_keys(:on, :message, :msg )
      names   = args
      if block_given? && args.length > 1
        raise ArgumentError.new("cannot supply a block for multiple requirements")
      end
      on = nil
      names.each do |name|
        raise ArgumentError.new( name.inspect ) unless name.is_a?( Symbol )
        case sprocket
        when StateFu::State
          on ||= [(options.delete(:on) || [:entry])].flatten
          sprocket.entry_requirements << name if on.include?( :entry )
          sprocket.exit_requirements  << name if on.include?( :exit  )
        when StateFu::Event
          sprocket.requirements << name
        end
        if block_given?
          machine.named_procs[name] = block
        end
        if msg = options.delete(:message) || options.delete(:msg)
          # TODO - move this into machine
          raise ArgumentError, msg.inspect unless [String, Symbol, Proc].include?(msg.class)
          machine.requirement_messages[name] = msg
        end
      end
    end
    alias_method :must,         :requires
    alias_method :must_be,      :requires
    alias_method :needs,        :requires
    alias_method :satisfy,      :requires
    alias_method :must_satisfy, :requires

    # create an event from *and* to the current state.
    # Creates a loop, useful (only) for hooking behaviours onto.
    def cycle( name=nil, options={}, &block )
      name ||= "cycle_#{sprocket.name.to_s}"
      require_sprocket( StateFu::State )
      evt = define_event( name, options, &block )
      evt.from sprocket
      evt.to   sprocket
      evt
    end

    #
    # state definition
    #

    # define the initial_state (otherwise defaults to the first state mentioned)
    def initial_state( *args, &block )
      require_no_sprocket()
      machine.initial_state= state( *args, &block)
    end

    # define a state; given a block, apply the block to a Lathe for the state
    def state( name, options={}, &block )
      require_no_sprocket()
      define_state( name, options, &block )
    end

    #
    # Event definition    
    # 
    
    # set the origin state(s) of an event (or, given a hash of symbols / arrays
    # of symbols, set both the origins and targets)
    # from :my_origin
    # from [:column_a, :column_b]
    # from :eden => :armageddon
    # from [:beginning, :prelogue] => [:ende, :prologue]
    def from *args, &block
      require_sprocket( StateFu::Event )
      sprocket.from( *args, &block )
    end

    # set the target state(s) of an event
    # to :destination
    # to [:end, :finale, :intermission]
    def to *args, &block
      require_sprocket( StateFu::Event )
      sprocket.to( *args, &block )
    end

    #
    # define chained events and states succinctly
    # usage: chain 'state1 -event1-> state2 -event2-> state3'
    def chain (string)
      rx_word    = /([a-zA-Z0-9_]+)/
      rx_state   = /^#{rx_word}$/
      rx_event   = /^-#{rx_word}->$/
      previous   = nil
      string.split.each do |chunk|
        case chunk
        when rx_state
          current = state($1)
          if previous.is_a?( StateFu::Event )
            previous.to( current )
          end
        when rx_event
          current = event($1)
          if previous.is_a?( StateFu::State )
            current.from( previous )
          end
        else
          raise ArgumentError, "'#{chunk}' is not a valid token"
        end
        previous = current
      end
    end

    #
    # Define a series of states at once, or return and iterate over all states yet defined
    #
    def states( *args, &block )
      require_no_sprocket()
      each_sprocket( 'state', *args, &block )
    end
    alias_method :all_states, :states
    alias_method :each_state, :states

    #
    # Define a series of events at once, or return and iterate over all events yet defined
    #
    def events( *args, &block )
      require_sprocket( NilClass, StateFu::State )
      each_sprocket( 'event', *args, &block )
    end
    alias_method :all_events, :events
    alias_method :each_event, :events

    # Bunch of silly little methods for defining events
     #:nodoc

    def before   *a, &b; require_sprocket( StateFu::Event ); define_hook :before,   *a, &b; end
    def on_exit  *a, &b; require_sprocket( StateFu::State ); define_hook :exit,     *a, &b; end
    def execute  *a, &b; require_sprocket( StateFu::Event ); define_hook :execute,  *a, &b; end
    def on_entry *a, &b; require_sprocket( StateFu::State ); define_hook :entry,    *a, &b; end
    def after    *a, &b; require_sprocket( StateFu::Event ); define_hook :after,    *a, &b; end
    def accepted *a, &b; require_sprocket( StateFu::State ); define_hook :accepted, *a, &b; end

    #
    #
    #
    
    private
    
    # require that the current sprocket be of a given type    
    def require_sprocket( *valid_types )
      raise ArgumentError.new("Lathe is for a #{sprocket.class}, not one of #{valid_types.inspect}") unless valid_types.include?( sprocket.class )
    end

    # ensure this is not a child lathe
    def require_no_sprocket()
      require_sprocket( NilClass )
    end

    # instantiate a child Lathe and apply the given block
    def apply_to( sprocket, options, &block )
      StateFu::Lathe.new( machine, sprocket, options, &block )
      sprocket
    end

    # abstract method for defining states / events
    def define_sprocket( type, name, options={}, &block )
      name       = name.to_sym
      klass      = StateFu.const_get((a=type.to_s.split('',2);[a.first.upcase, a.last].join))
      collection = machine.send("#{type}s")
      options.symbolize_keys!
      if sprocket = collection[name]
        apply_to( sprocket, options, &block )
        sprocket
      else
        sprocket = klass.new( machine, name, options )
        collection << sprocket
        apply_to( sprocket, options, &block )
        sprocket
      end
    end

     #:nodoc
    def define_state( name, options={}, &block )
      define_sprocket( :state, name, options, &block )
    end

     #:nodoc
    def define_event( name, options={}, &block )
      define_sprocket( :event, name, options, &block )
    end
    
     #:nodoc
    def define_hook slot, method_name=nil, &block
      unless sprocket.hooks.has_key?( slot )
        raise ArgumentError, "invalid hook type #{slot.inspect} for #{sprocket.class}"
      end
      if block_given?
        # unless (-1..1).include?( block.arity )
        #   raise ArgumentError, "unexpected block arity: #{block.arity}"
        # end
        case method_name
        when Symbol
          machine.named_procs[method_name] = block
          hook = method_name
        when NilClass
          hook = block
          # allow only one anonymous hook per slot in the interests of
          # sanity - replace any pre-existing ones
          sprocket.hooks[slot].delete_if { |h| Proc === h }
        else
          raise ArgumentError.new( method_name.inspect )
        end
      elsif method_name.is_a?( Symbol ) # no block
        hook = method_name
        # prevent duplicates
        sprocket.hooks[slot].delete_if { |h| hook == h }
      else
        raise ArgumentError, "#{method_name.class} is not a symbol"
      end
      sprocket.hooks[slot] << hook
    end

     #:nodoc
    def each_sprocket( type, *args, &block)
      options = args.extract_options!.symbolize_keys!
      if args.empty? || args  == [:ALL] 
        args = machine.send("#{type}s").except( options.delete(:except) )
      end
      args.map { |name| self.send( type, name, options.dup, &block) }.extend StateArray
    end

  end
end

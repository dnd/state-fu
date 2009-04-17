module StateFu
  class Lathe

    # NOTE: Sprocket is the abstract superclass of Event and State

    attr_reader :machine, :sprocket, :options

    def initialize( machine, sprocket = nil, options={}, &block )
      @machine  = machine
      @sprocket = sprocket
      @options  = options.symbolize_keys!
      if sprocket
        sprocket.apply!( options )
      end
      if block_given?
        if block.arity == 1
          yield self
        else
          instance_eval( &block )
        end
      end
    end

    private

    # a 'child' lathe is created by apply_to, to deal with nested
    # blocks for states / events ( which are sprockets )
    def child?
      !!@sprocket
    end

    # is this the toplevel lathe for a machine?
    def master?
      !child?
    end

    # instantiate a child lathe and apply the given block
    def apply_to( sprocket, options, &block )
      StateFu::Lathe.new( machine, sprocket, options, &block )
      sprocket
    end

    # require that the current sprocket be of a given type
    def require_sprocket( *valid_types )
      raise ArgumentError.new("Lathe is for a #{sprocket.class}, not one of #{valid_types.inspect}") unless valid_types.include?( sprocket.class )
    end

    # ensure this is not a child lathe
    def require_no_sprocket()
      require_sprocket( NilClass )
    end

    # abstract method for defining states / events
    def define_sprocket( type, name, options={}, &block )
      name       = name.to_sym
      klass      = StateFu.const_get((a=type.to_s.split('',2);[a.first.upcase, a.last].join))
      collection = machine.send("#{type}s")
      options.symbolize_keys!
      if sprocket = collection[name]
        apply_to( sprocket, options, &block )
      else
        sprocket = klass.new( machine, name, options )
        collection << sprocket
        apply_to( sprocket, options, &block )
        sprocket
      end
    end

    def define_state( name, options={}, &block )
      define_sprocket( :state, name, options, &block )
    end

    def define_event( name, options={}, &block )
      define_sprocket( :event, name, options, &block )
    end

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

    public

    # helpers are mixed into all binding / transition contexts
    def helper( *modules )
      machine.helper *modules
    end

    #
    # event definition
    #

    def event( name, options={}, &block )
      options.symbolize_keys!
      require_sprocket( StateFu::State, NilClass )
      if child? && sprocket.is_a?( StateFu::State ) # in state block
        target  = options.delete(:to)
        evt     = define_event( name, options, &block )
        evt.from sprocket
        evt.to( target )
      else # in event block
        origin = options.delete( :from )
        target = options.delete( :to )
        evt    = define_event( name, options, &block )
        evt.from origin unless origin.nil?
        evt.to   target unless target.nil?
        evt
      end
    end

    def events( *args, &block )
      require_no_sprocket()
      options = args.extract_options!.symbolize_keys!
      args.each { |name| event( name.to_sym, options, &block) }
    end

    def requires( name, options={}, &block )
      require_sprocket( StateFu::Event, StateFu::State )
      options.symbolize_keys!
      raise ArgumentError.new( name.inspect ) unless name.is_a?( Symbol )
      case sprocket
      when StateFu::State
        on = [(options.delete(:on) || [:entry])].flatten
        sprocket.entry_requirements << name if on.include?( :entry )
        sprocket.exit_requirements  << name if on.include?( :exit  )
      when StateFu::Event
        sprocket.requirements << name
      end
      if block_given?
        #unless (-1..1).include?( block.arity )
        #  raise ArgumentError, "unexpected block arity: #{block.arity}"
        #end
        machine.named_procs[name] = block
      end
    end
    alias_method :must,         :requires
    alias_method :must_be,      :requires
    alias_method :needs,        :requires
    alias_method :satisfy,      :requires
    alias_method :must_satisfy, :requires

    # create an event from *and* to the current state.
    # Creates a loop, useful (only) for hooking behaviours onto.
    def cycle( name, options={}, &block )
      require_sprocket( StateFu::State )
      evt = define_event( name, options, &block )
      evt.from sprocket
      evt.to   sprocket
      evt
      # raise NotImplementedError
    end

    #
    # state definition
    #

    def initial_state( *args, &block )
      require_no_sprocket()
      machine.initial_state= state( *args, &block)
    end

    def state( name, options={}, &block )
      require_no_sprocket()
      define_state( name, options, &block )
    end

    def states( *args, &block )
      require_no_sprocket()
      options = args.extract_options!.symbolize_keys!
      args.each { |name| state( name, options, &block) }
    end

    # TODO - add support for :all, :except, :only
    #
    # Sets event.origin and optionally event.target.
    # both can be supplied as a symbol, array of symbols.
    # any states referenced here will be created if they do not exist.
    def from *args, &block
      require_sprocket( StateFu::Event )
      options           = args.extract_options!.symbolize_keys!
      sprocket.origin     = args
      to                = options.delete(:to)
      to && sprocket.target = to
      if block_given?
        apply_to( sprocket, options, &block )
      else
        apply_to( sprocket, options )
      end
    end

    # TODO - add support for :all, :except, :only
    #
    # Sets event.target
    # can be supplied as a symbol, or array of symbols.
    # any states referenced here will be created if they do not exist.
    def to *args
      options         = args.extract_options!.symbolize_keys!
      sprocket.target = args
      if block_given?
        apply_to( sprocket, options, &block )
      else
        apply_to( sprocket, options )
      end
    end

    def all_states *a, &b
      raise NotImplementedError
    end

    # Bunch of silly little methods for defining events

    def before   *a, &b; require_sprocket( StateFu::Event ); define_hook :before,   *a, &b; end
    def on_exit  *a, &b; require_sprocket( StateFu::State ); define_hook :exit,     *a, &b; end
    def execute  *a, &b; require_sprocket( StateFu::Event ); define_hook :execute,  *a, &b; end
    def on_entry *a, &b; require_sprocket( StateFu::State ); define_hook :entry,    *a, &b; end
    def after    *a, &b; require_sprocket( StateFu::Event ); define_hook :after,    *a, &b; end
    def accepted *a, &b; require_sprocket( StateFu::State ); define_hook :accepted, *a, &b; end

  end
end

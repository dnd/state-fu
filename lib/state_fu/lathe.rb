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
      raise ArgumentError.new unless valid_types.include?( sprocket.class )
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
      hook = block_given? ? block : method_name
      unless sprocket.hooks.has_key?( slot )
        raise ArgumentError, "invalid hook type #{slot.inspect} for #{sprocket.class}"
      end
      case hook
      when Proc
        unless (-1..1).include?( hook.arity )
          raise ArgumentError, "unexpected block arity: #{hook.arity}"
        end
        # only one anonymous proc per hook - clobber any existing ones.
        sprocket.hooks[slot].delete_if { |h| Proc === h }
      when Symbol
        # prevent duplicate named hooks
        sprocket.hooks[slot].delete_if { |h| hook == h }
      else
        raise ArgumentError, hook.class.to_s
      end
      sprocket.hooks[slot] << hook
    end

    public

    # helpers are mixed into all binding / transition contexts
    # use them to bend the language to your will
    def helper( *modules )
      machine.helpers += modules
      machine.helpers.extend( HelperArray )
      raise NotImplementedError

      # names.each do |name|
      #   const_name = name.to_s.camelize
      #   # if we can't find it now, try later in the machinist object's context
      #   machine.helpers << (const_name.constantize rescue const_name )
      # end
    end

    #
    # event definition
    #

    def event( name, options={}, &block )
      require_sprocket( StateFu::State, NilClass )
      if child? && sprocket.is_a?( StateFu::State ) # in state block
        target  = options.symbolize_keys!.delete(:to)
        evt     = define_event( name, options, &block )
        evt.from sprocket
        evt.to( target ) if target
      else
        define_event( name, options, &block )
      end
    end

    def events( *args, &block )
      require_no_sprocket()
      options = args.extract_options!.symbolize_keys!
      args.each { |name| event( name.to_sym, options, &block) }
    end

    def needs *a, &b
      require_sprocket( StateFu::Event )
      raise NotImplementedError
    end

    # create an event from *and* to the current state.
    # Creates a loop, useful (only) for hooking behaviours onto.
    def cycle( name, options={}, &block )
      require_sprocket( StateFu::State )
      raise NotImplementedError
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
      options       = args.extract_options!.symbolize_keys!
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

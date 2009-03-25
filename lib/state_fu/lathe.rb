module StateFu
  class Lathe

    attr_reader :machine, :sprocket, :options

    def self.parse( machine, sprocket = nil, options={}, &block )
      new( machine, sprocket = nil, options={}, &block )
    end

    def initialize( machine, sprocket = nil, options={}, &block )
      @machine   = machine
      @sprocket = sprocket
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

    def sprocket?
      !!@sprocket
    end
    alias_method :child?, :sprocket?

    def apply_to( sprocket, options, &block )
      StateFu::Lathe.new( machine, sprocket, options, &block )
      sprocket
    end

    def require_sprocket( *valid_types )
      # raise ArgumentError.new unless valid_types.include?( sprocket.class )
    end

    def require_no_sprocket()
      require_sprocket( NilClass )
    end

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

    def define_hook *args, &block # type, names, options={}, &block
      options      = args.extract_options!.symbolize_keys!
      type         = args.shift
      method_names = args
      Logger.info "define_hook: not implemented"
    end

    public

    # helpers are mixed into all binding / transition contexts
    # use them to bend the language to your will
    def helper( *names )
      names.each do |name|
        const_name = name.to_s.camelize
        # if we can't find it now, try later in the machinist object's context
        machine.helpers << (const_name.constantize rescue const_name )
      end
    end

    #
    # event definition
    #

    def event( name, options={}, &block )
      require_sprocket( StateFu::State, NilClass )
      if sprocket? && sprocket.is_a?( StateFu::State ) # in state block
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
      # ...
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

    # def all_states *a, &b
    #   Logger.info "<StateFu::Lathe.all_states not implemented>"
    # end

    # Bunch of silly little methods for defining events
    def before   *a, &b; require_sprocket( StateFu::Event ); define_hook :before,   *a, &b; end
    def on_exit  *a, &b; require_sprocket( StateFu::State ); define_hook :exit,     *a, &b; end
    def execute  *a, &b; require_sprocket( StateFu::Event ); define_hook :execute,  *a, &b; end
    def on_entry *a, &b; require_sprocket( StateFu::State ); define_hook :entry,    *a, &b; end
    def after    *a, &b; require_sprocket( StateFu::Event ); define_hook :after,    *a, &b; end
    def accepted *a, &b; require_sprocket( StateFu::State ); define_hook :accepted, *a, &b; end

  end
end

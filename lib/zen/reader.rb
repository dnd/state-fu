module Zen
  class Reader

    attr_reader :koan, :phrase, :options

    def self.parse( koan, phrase = nil, options={}, &block )
      new( koan, phrase = nil, options={}, &block )
    end

    def initialize( koan, phrase = nil, options={}, &block )
      @koan   = koan
      @phrase = phrase
      if phrase
        phrase.apply!( options )
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

    def phrase?
      !!@phrase
    end
    alias_method :child?, :phrase?

    def apply_to( phrase, options, &block )
      Zen::Reader.new( koan, phrase, options, &block )
      phrase
    end

    def require_phrase( *valid_types )
      # raise ArgumentError.new unless valid_types.include?( phrase.class )
    end

    def require_no_phrase()
      require_phrase( NilClass )
    end

    def define_phrase( type, name, options={}, &block )
      name       = name.to_sym
      klass      = Zen.const_get((a=type.to_s.split('',2);[a.first.upcase, a.last].join))
      collection = koan.send("#{type}s")
      options.symbolize_keys!
      if phrase = collection[name]
        apply_to( phrase, options, &block )
      else
        phrase = klass.new( koan, name, options )
        collection << phrase
        apply_to( phrase, options, &block )
        phrase
      end
    end

    def define_state( name, options={}, &block )
      define_phrase( :state, name, options, &block )
    end

    def define_event( name, options={}, &block )
      define_phrase( :event, name, options, &block )
    end

    def define_hook *args, &block # type, names, options={}, &block
      options      = args.extract_options!.symbolize_keys!
      type         = args.shift
      method_names = args
      Logger.info "define_hook: not implemented"
    end

    public

    #
    # event definition
    #

    def event( name, options={}, &block )
      require_phrase( Zen::State, NilClass )
      if phrase? && phrase.is_a?( Zen::State ) # in state block
        target  = options.delete(:to)
        evt     = define_event( name, options, &block )
        evt.from phrase
        evt.to( target ) if target
      else
        define_event( name, options, &block )
      end
    end

    def events( *args, &block )
      require_no_phrase()
      options = args.extract_options!.symbolize_keys!
      args.each { |name| event( name.to_sym, options, &block) }
    end

    def needs *a, &b
      require_phrase( Zen::Event )
      # ...
    end

    #
    # state definition
    #

    def initial_state( *args, &block )
      require_no_phrase()
      koan.initial_state= state( *args, &block)
    end

    def state( name, options={}, &block )
      require_no_phrase()
      define_state( name, options, &block )
    end

    def states( *args, &block )
      require_no_phrase()
      options = args.extract_options!.symbolize_keys!
      args.each { |name| state( name, options, &block) }
    end

    # TODO - add support for :all, :except, :only
    #
    # Sets event.origin and optionally event.target.
    # both can be supplied as a symbol, array of symbols.
    # any states referenced here will be created if they do not exist.
    def from *args, &block
      require_phrase( Zen::Event )
      options           = args.extract_options!.symbolize_keys!
      phrase.origin     = args
      to                = options.delete(:to)
      to && phrase.target = to
      if block_given?
        apply_to( phrase, options, &block )
      else
        apply_to( phrase, options )
      end
    end

    # TODO - add support for :all, :except, :only
    #
    # Sets event.target
    # can be supplied as a symbol, or array of symbols.
    # any states referenced here will be created if they do not exist.
    def to *args
      options       = args.extract_options!.symbolize_keys!
      phrase.target = args
      if block_given?
        apply_to( phrase, options, &block )
      else
        apply_to( phrase, options )
      end
    end

    # def all_states *a, &b
    #   Logger.info "<Zen::Reader.all_states not implemented>"
    # end

    # Bunch of silly little methods for defining events
    def before   *a, &b; require_phrase( Zen::Event ); define_hook :before,   *a, &b; end
    def on_exit  *a, &b; require_phrase( Zen::State ); define_hook :exit,     *a, &b; end
    def execute  *a, &b; require_phrase( Zen::Event ); define_hook :execute,  *a, &b; end
    def on_entry *a, &b; require_phrase( Zen::State ); define_hook :entry,    *a, &b; end
    def after    *a, &b; require_phrase( Zen::Event ); define_hook :after,    *a, &b; end
    def accepted *a, &b; require_phrase( Zen::State ); define_hook :accepted, *a, &b; end

  end
end

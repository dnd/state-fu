module StateFu
  class Machine
    include Helper

    DEFAULT_FIELD_NAME_SUFFIX = '_state'

    # meta-constructor; expects to be called via Klass.machine()
    def self.for_class(klass, name, options={}, &block)
      options.symbolize_keys!
      name = name.to_sym
      unless machine = StateFu::FuSpace.class_machines[ klass ][ name ]
        machine = new( name, options, &block )
        machine.bind!( klass, name, options[:field_name] )
      end
      if block_given?
        machine.apply!( &block )
      end
      machine
    end

    ##
    ## Instance Methods
    ##

    attr_reader :states, :events, :options, :helpers, :named_procs, :requirement_messages

    def initialize( name, options={}, &block )
      @states  = [].extend( StateArray  )
      @events  = [].extend( EventArray  )
      @helpers = [].extend( HelperArray )
      @named_procs          = {}
      @requirement_messages = {}
      @options              = options
    end

    # merge the commands in &block with the existing machine; returns
    # a lathe for the machine.
    def apply!( &block )
      StateFu::Lathe.new( self, &block )
    end
    alias_method :lathe, :apply!

    def helper_modules
      helpers.map do |h|
        case h
        when String, Symbol
          Object.const_get( h.to_s.classify )
        when Module
          h
        else
          raise ArgumentError.new( h.class.inspect )
        end
      end
    end

    def inject_helpers_into( obj )
      metaclass = class << obj; self; end

      mods = helper_modules()
      metaclass.class_eval do
        mods.each do |mod|
          include( mod )
        end
      end
    end

    # the modules listed here will be mixed into Binding and
    # Transition objects for this machine. use this to define methods,
    # references or data useful to you during transitions, event
    # hooks, or in general use of StateFu.
    #
    # They can be supplied as a string/symbol (as per rails controller
    # helpers), or a Module.
    #
    # To do this globally, just duck-punch StateFu::Machine /
    # StateFu::Binding.
    def helper *modules_to_add
      modules_to_add.each { |mod| helpers << mod }
    end

    # make it so a class which has included StateFu has a binding to
    # this machine
    def bind!( klass, name=StateFu::DEFAULT_MACHINE, field_name = nil )
      field_name ||= name.to_s.underscore.tr(' ', '_') + DEFAULT_FIELD_NAME_SUFFIX
      field_name   = field_name.to_sym
      StateFu::FuSpace.insert!( klass, self, name, field_name )
      # define an accessor method with the given name
      unless name == StateFu::DEFAULT_MACHINE
        klass.class_eval do
          define_method name do
            state_fu( name )
          end
        end
      end
    end

    def empty?
      states.empty?
    end

    def initial_state=( s )
      case s
      when Symbol, String, StateFu::State
        unless init_state = states[ s.to_sym ]
          init_state = StateFu::State.new( self, s.to_sym )
          states << init_state
        end
        @initial_state = init_state
      else
        raise( ArgumentError, s.inspect )
      end
    end

    def initial_state()
      @initial_state ||= states.first
    end

    def state_names
      states.map(&:name)
    end

    def event_names
      events.map(&:name)
    end

    # given a messy bunch of symbols, find or create a list of
    # matching States.
    def find_or_create_states_by_name( *args )
      args = args.compact.flatten
      raise ArgumentError.new( args.inspect ) unless args.all? { |a| [Symbol, StateFu::State].include? a.class }
      args.map do |s|
        unless state = states[s.to_sym]
          # TODO clean this line up
          state = s.is_a?( StateFu::State ) ? s : StateFu::State.new( self, s )
          self.states << state
        end
        state
      end
    end

    def inspect
      "#<#{self.class} ##{__id__} states=#{state_names.inspect} events=#{event_names.inspect} options=#{options.inspect}>"
    end

  end
end

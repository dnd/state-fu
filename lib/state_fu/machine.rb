module StateFu
  #
  # TODO - rename to ... Machine ?
  #
  class Machine
    include Helper

    DEFAULT_FIELD_NAME_SUFFIX = '_state'

    # analogous to self.for_class, but keeps machines in
    # global space, not tied to a specific class.
    # def self.[] name, options, &block
    #   # is there a use case for this or is it just unneccesary complexity?
    #   raise "pending"
    # end

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

    attr_reader :states, :events, :options, :helpers

    def initialize( name, options={}, &block )
      @states  = [].extend( StateArray  )
      @events  = [].extend( EventArray  )
      @helpers = [].extend( HelperArray )
      @options = options
    end

    # merge the commands in &block with the existing machine
    def apply!( &block )
      StateFu::Lathe.new( self, &block )
    end

    # the modules listed here will be mixed into Binding and
    # Transition objects for this machine. use this to define methods,
    # references or data useful to you during transitions, event
    # hooks, or in general use of StateFu.
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
    def find_or_create_states_by_name( *names )
      names.flatten.select do |s|
        s.is_a?( Symbol ) || s.is_a?( StateFu::State )
      end.map do |s|
        unless state = states[s.to_sym]
          state = s.is_a?( StateFu::State ) ? s : StateFu::State.new( self, s )
          self.states << state
        end
        state
      end
    end

  end
end

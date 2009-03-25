module StateFu
  #
  # TODO - rename to ... Machine ?
  #
  class Machine
    include Helper

    # analogous to self.for_class, but keeps machines in
    # global space, not tied to a specific class.
    def self.[] name, options, &block
      # ...
    end

    # meta-constructor; expects to be called via Klass.machine()
    def self.for_class(klass, name, options={}, &block)
      options.symbolize_keys!
      name = name.to_sym
      unless machine = StateFu::Space.class_machines[ klass ][ name ]
        machine = new( name, options, &block )
        machine.teach!( klass, name, options[:field_name] )
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
      StateFu::Reader.new( self, &block )
    end

    # the Machine teaches a class how to meditate on it:
    def teach!( klass, name=StateFu::DEFAULT_KOAN, field_name = nil )
      field_name ||= name.to_s.downcase.tr(' ', '_') + "_state"
      field_name   = field_name.to_sym
      StateFu::Space.insert!( klass, self, name, field_name )
    end
    alias_method :bind!, :teach!

    def empty?
      states.empty?
    end

    def initial_state=( state )
      unless state.is_a?( StateFu::State )
        state = states[ state.to_sym ] || raise( ArgumentError, state.inspect )
      end
      @initial_state = state
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
      end.map do |name|
        unless state = states[name.to_sym]
          state = StateFu::State.new( self, name )
          self.states << state
        end
        state
      end
    end

  end
end

module Zen
  #
  #
  class Koan
    include Helper

    # analogous to self.for_class, but keeps koans in
    # global space, not tied to a specific class.
    def self.[] name, options, &block
      # ...
    end

    # meta-constructor; expects to be called via Klass.koan()
    def self.for_class(klass, name, options={}, &block)
      options.symbolize_keys!
      name = name.to_sym
      unless koan = Zen::Space.class_koans[ klass ][ name ]
        koan = new( name, options, &block )
        koan.teach!( klass, name, options[:field_name] )
      end
      if block_given?
        koan.apply!( &block )
      end
      koan
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

    # merge the commands in &block with the existing koan
    def apply!( &block )
      Zen::Reader.new( self, &block )
    end

    # the Koan teaches a class how to meditate on it:
    def teach!( klass, name=Zen::DEFAULT_KOAN, field_name = nil )
      field_name ||= name.to_s.downcase.tr(' ', '_') + "_state"
      field_name   = field_name.to_sym
      Zen::Space.insert!( klass, self, name, field_name )
    end
    alias_method :bind!, :teach!

    def empty?
      states.empty?
    end

    def initial_state=( state )
      unless state.is_a?( Zen::State )
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
        s.is_a?( Symbol ) || s.is_a?( Zen::State )
      end.map do |name|
        unless state = states[name.to_sym]
          state = Zen::State.new( self, name )
          self.states << state
        end
        state
      end
    end

  end
end

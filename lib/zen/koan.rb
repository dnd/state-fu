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
    def self.for_class(klass, name, options, &block)
      options.symbolize_keys!
      name = name.to_sym
      koan = Zen::Space.class_koans[ klass ][ name ]
      if block_given?
        if koan
          koan.learn!( &block )
        else
          koan = new( name, options, &block )
          koan.learn!( &block )
          koan.teach!( klass, name, options[:field_name] )
          koan
        end
      else
        koan
      end
    end

    ##
    ##
    ##

    attr_reader :states, :events

    def initialize( *a, &block )
      @states = [].extend( ArraySmartIndex )
      @events = [].extend( ArraySmartIndex )
    end

    # merge the commands in &block with the existing koan
    def learn!( &block )
      Zen::Reader.parse( self, &block )
    end
    alias_method :merge!, :learn!
    alias_method :merge, :learn!
    alias_method :parse!, :learn!
    alias_method :parse, :learn!

    # the Koan teaches a class how to meditate on it:
    def teach!( klass, name=Zen::DEFAULT_KOAN, field_name = nil )
      field_name ||= name.to_s.downcase.tr(' ', '_') + "_state"
      field_name   = field_name.to_sym
      Zen::Space.insert!( klass, self, name, field_name )
    end
    alias_method :bind!, :teach!

    def state_names
      states.map(&:name)
    end

    def event_names
      events.map(&:name)
    end

    def define_event( name, options={}, &block )
      name = name.to_sym
      options.symbolize_keys!
      if existing_event = self.events[name]
        existing_event.update!( options, &block)
      else
        new_event = Zen::Event.new( self, name, options, &block )
        self.events << new_event
        new_event
      end
    end

    def define_state( name, options={}, &block )
      name = name.to_sym
      options.symbolize_keys!
      if existing_state = self.states[name]
        existing_state.update!(options, &block)
      else
        new_state = Zen::State.new( self, name, options, &block )
        self.states << new_state
        new_state
      end
    end

    def find_or_create_states_by_name( *names )
      names.flatten.select do |s|
        s.is_a?(Symbol)
      end.map do |name|
        unless _state = states[name]
          _state = Zen::State.new( self, name )
          states << _state
          _state
        end
      end
    end

  end
end

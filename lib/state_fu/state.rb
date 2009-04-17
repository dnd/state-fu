module StateFu
  class State < StateFu::Sprocket

    attr_reader :entry_requirements, :exit_requirements

    def initialize(machine, name, options={})
      @entry_requirements = [].extend ArrayWithSymbolAccessor
      @exit_requirements  = [].extend ArrayWithSymbolAccessor
      super( machine, name, options )
    end

    def events
      machine.events.from(self)
    end

    #
    # Proxy methods to StateFu::Lathe
    #
    # TODO - build something meta to build these proxy events
    def event( name, options={}, &block )
      if block_given?
        lathe.event( name, options, &block )
      else
        lathe.event( name, options )
      end
    end

  end
end

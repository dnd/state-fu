module StateFu
  class State < StateFu::Phrase

    def events
      machine.events.from(self)
    end

    #
    # Proxy methods to StateFu::Lathe
    #
    # TODO - build something meta to build these proxy events
    def event( name, options={}, &block )
      lathe.event( name, options, &block )
    end

  end
end

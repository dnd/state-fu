module StateFu
  class State < StateFu::Phrase

    def events
      machine.events.from(self)
    end

    #
    # Proxy methods to StateFu::Reader
    #
    # TODO - build something meta to build these proxy events
    def event( name, options={}, &block )
      reader.event( name, options, &block )
    end

  end
end

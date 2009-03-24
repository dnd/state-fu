module Zen
  class State < Zen::Phrase

    def events
      koan.events.from(self)
    end

    #
    # Proxy methods to Zen::Reader
    #
    # TODO - build something meta to build these proxy events
    def event( name, options={}, &block )
      reader.event( name, options, &block )
    end

  end
end

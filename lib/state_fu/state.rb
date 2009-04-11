module StateFu
  class State < StateFu::Sprocket

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

module Zen
  class State < Zen::Phrase

    # define an event - used while reading a koan

    def event( name, options={}, &block )
      target  = options.delete(:to)
      evt     = koan.define_event( name, options, &block )
      evt.from self
      evt.to( target ) if target
    end

  end
end

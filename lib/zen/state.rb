module Zen
  class State
    # DRY up duplicated code
    include Zen::Interfaces::State

    # WARNING duplicated in Zen::Reader
    def event( name, options={}, &block )
      target  = options.delete(:to)
      evt     = koan.define_event( name, options, &block )
      evt.from self
      evt.to( target ) if target
    end

  end
end

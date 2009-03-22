module Zen
  class State
    # DRY up duplicated code
    include Zen::Interfaces::State

    # WARNING duplicated in Zen::Reader
    def event( name, options={}, &block )
      koan.define_event( name, options, &block )
    end

  end
end

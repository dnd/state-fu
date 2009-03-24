module Zen

  class TransitionHalted < Exception
    attr_reader :foo

    def initialize( _self, message, options={} )
    end
  end

end

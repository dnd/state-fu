module StateFu

  class Exception < ::Exception
    attr_reader :binding
  end

  class TransitionHalted < Exception
    attr_reader :transition

    def initialize( _self, message, options={} )
    end
  end

  class InvalidTransition < Exception
    attr_reader :binding, :origin, :target, :args
    DEFAULT_MESSAGE = "An invalid transition was attempted"
    def initialize( binding, origin, target, message=nil, options={})
      @binding = binding
      @origin  = origin
      @target  = target
      @message = message
      @options = options
    end
  end

end

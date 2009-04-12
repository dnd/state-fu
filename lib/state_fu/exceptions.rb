module StateFu

  class Exception < ::Exception
    attr_reader :binding
  end

  class TransitionHalted < Exception
    attr_reader :transition
    DEFAULT_MESSAGE = "The transition was halted"
    def initialize( transition, message=DEFAULT_MESSAGE )
      @transition = transition
      @message    = message
    end
  end

  class InvalidTransition < Exception
    attr_reader :binding, :origin, :target, :args
    DEFAULT_MESSAGE = "An invalid transition was attempted"

    def initialize( binding, event, origin, target, message=DEFAULT_MESSAGE, options={})
      @binding = binding
      @origin  = origin
      @target  = target
      @message = message
      @options = options
    end
  end

end

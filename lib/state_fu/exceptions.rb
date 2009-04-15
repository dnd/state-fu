module StateFu

  class Exception < ::Exception
    attr_reader :binding, :options
  end

  class TransitionHalted < Exception
    attr_reader :transition
    DEFAULT_MESSAGE = "The transition was halted"
    def initialize( transition, message=DEFAULT_MESSAGE, options={})
      @transition = transition
      @options    = options
      super( message )
    end
  end

  class InvalidTransition < Exception
    attr_reader :binding, :origin, :target, :event, :args
    DEFAULT_MESSAGE = "An invalid transition was attempted"

    def initialize( binding, event, origin, target, message=DEFAULT_MESSAGE, options={})
      @binding = binding
      @event   = event
      @origin  = origin
      @target  = target
      @options = options
      super( message )
    end
  end

end

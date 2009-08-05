module StateFu

  class MagicMethodError < NoMethodError
  end

  class Error < ::StandardError
    attr_reader :binding, :options

    def initialize binding, message=nil, options={}
      @binding = binding
      @options = options
      super message
    end
    
  end

  class TransitionNotFound < Error
  end
  
  class TransitionError < Error
    # TODO default message
    attr_reader :transition

    def initialize transition, message=nil, options={}
      raise caller.inspect unless transition.is_a?(Transition)
      @transition = transition 
      super transition.binding, message, options
    end

    delegate :origin, :to => :transition
    delegate :target, :to => :transition
    delegate :event,  :to => :transition    
    delegate :args,   :to => :transition    

    # TODO capture these on initialization
    delegate :unmet_requirements,         :to => :transition        
    delegate :unmet_requirement_messages, :to => :transition            
    delegate :requirement_errors,         :to => :transition            

    def inspect
      origin_name = origin && origin.name
      target_name = target && target.name
      event_name  = event  && event.name  
      "<#{self.class.to_s} #{message} #{origin_name.inspect}=[#{event_name.inspect}]=>#{target_name.inspect}>"
    end
  end

  class UnknownTarget < TransitionError
  end

  class TransitionAlreadyFired < TransitionError
  end
  
  class RequirementError < TransitionError
    def to_a
      unmet_requirement_messages
    end
    
    def to_h
      requirement_errors
    end
  end

  class TransitionHalted < TransitionError
  end

  class InvalidTransition < TransitionError
    attr_reader :valid_transitions

    def initialize transition, message=nil, valid_transitions=nil, options={}
      @valid_transitions = valid_transitions
      super transition, message, options
    end
    
  end

end

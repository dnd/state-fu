module StateFu
  #
  # delegator class for evaluation methods / procs in the context of
  # your object.
  #
  
  # There's a bug in ruby 1.8.x where lambda {}.arity == -1 instead of 0
  # To get around this, turn it into a proc if conditions are dangerous.
  def self.get_effective_arity
    if RUBY_VERSION[0,3] == "1.8" && proc.arity == -1
      proc.to_proc.arity
    else
      proc.arity
    end    
  end
  
  class Executioner

    # give us a blank slate
    # instance_methods.each { |m| undef_method m unless m =~ /(^__|^self|^nil\?$|^send$|proxy_|^object_id|^respond_to\?|^instance_exec|^instance_eval|^method$)/ }

    def initialize transition, &block
      @transition     = transition
      @__target__     = transition.object
      @__self___      = self
      yield self if block_given?
      # forces method_missing to snap back to its pre-state-fu condition:
      # @__target__.initialize_state_fu!
      self
    end

    # delegate :self, :to => :__target__

    delegate :origin,  :to => :transition, :prefix => true # transition_origin
    delegate :target,  :to => :transition, :prefix => true # transition_target
    delegate :event,   :to => :transition, :prefix => true # transition_event

    delegate :halt!,   :to => :transition
    delegate :args,    :to => :transition
    delegate :options, :to => :transition

    def binding
      transition.binding
    end

    attr_reader :transition, :__target__, :__self__

    alias_method :t,                  :transition
    alias_method :current_transition, :transition
    alias_method :context,            :transition
    alias_method :ctx,                :transition

    alias_method :arguments,            :args
    alias_method :transition_arguments, :args

    # delegate :machine, :to => :binding
    #delegate :states,  :to => :machine


    def machine 
      binding.machine
    end
    
    def states
      # puts binding
      # puts binding.instance_eval() { @machine }
      # puts binding.machine
      # puts binding.machine.states.names
      # puts machine
      # puts machine.states
      # machine.states
    end
    # delegate :machine, :to => :transition

    def evaluate_with_arguments method_name_or_proc, *arguments
      if method_name_or_proc.is_a?(Proc) && meth = method_name_or_proc
      elsif meth = transition.machine.named_procs[method_name_or_proc]
      elsif respond_to?( method_name_or_proc) && meth = method(method_name_or_proc)        
      elsif method_name_or_proc.to_s =~ /^not?_(.*)$/
        # special case: prefix a method with no_ or not_ and get the 
        # boolean opposite of its evaluation result
        return !( evaluate_with_arguments $1, *args )
      else
        raise NoMethodError.new( "undefined method_name `#{method_name_or_proc.to_s}' for \"#{__target__}\":#{__target__.class.to_s}" )
      end      

      if arguments.length < meth.arity.abs && meth.arity != -1
        # ensure we don't have too few arguments
        raise ArgumentError.new([meth.arity, arguments.length].inspect) 
      else
        # ensure we don't pass too many arguments
        arguments = arguments[0, meth.arity.abs]
      end
      
      # execute it!
      __target__.with_methods_on(self) do
        self.instance_exec *arguments, &meth
      end
    end

    def evaluate method_name_or_proc
      arguments = [transition, args, __target__]
      evaluate_with_arguments(method_name_or_proc, *arguments)
    end

    alias_method :executioner_respond_to?, :respond_to?

    def respond_to? method_name, include_private = false
      executioner_respond_to?(method_name, include_private) ||
      __target__.__send__( :respond_to?, method_name, include_private )
    end

    alias_method :executioner_method, :method
    def method method_name
      begin
        executioner_method(method_name)
      rescue NameError
        __target__.__send__ :method, method_name
      end
    end

    private

    # Forwards any missing method call to the \target.
    # TODO / FIXME / NOTE: we don't (can't ?) handle block arguments ...    
    def method_missing(method_name, *args)
      if __target__.respond_to?(method_name, true)
        begin
          meth = __target__.__send__ :method, method_name
        rescue NameError
          super
        end
        __target__.instance_exec( *args, &meth)
      else # let's hope it's a named proc
        evaluate_with_arguments(method_name, *args)
      end
      
    end

#    # Forwards any missing method call to the \target.
#    def self.const_missing(const_name)
#      unless __target__.class.const_defined?(const_name, true)
#        super(const_name)
#      end
#      __target__.class.const_get(const_name)
#    end
#
  end
end

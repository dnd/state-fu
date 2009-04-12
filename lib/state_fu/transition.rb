module StateFu

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  class Transition
    include StateFu::Helper
    attr_reader(  :binding,
                  :origin,
                  :target,
                  :event,
                  :args,
                  :errors,
                  :object,
                  :options,
                  :current_hook )

    attr_accessor :only_pretend

    def initialize( binding, event, target=nil, *args, &block )
      # ensure event is a StateFu::Event
      if event.is_a?( Symbol )
        event = binding.machine.events[ event ]
      end
      if !event.is_a?( StateFu::Event )
        raise ArgumentError, event.inspect
      end

      # ensure target is a valid StateFu::State
      if target.nil?
        if event.target.is_a?( Array ) && event.target.length == 1
          target = event.target.first
        else
          raise( ArgumentError, "target cannot be determined" )
        end
      end
      if target.is_a?( Symbol )
        target = binding.machine.states[ target ]
      end
      unless event.target.include?( target )
        err_msg = "Illegal target #{target}"
        raise( StateFu::InvalidTransition.new( binding,
                                               event,
                                               binding.current_state,
                                               target,
                                               err_msg ))
      end

      @options    = args.extract_options!.symbolize_keys!
      @binding    = binding
      @object     = binding.object
      @origin     = binding.current_state
      @target     = target
      @event      = event
      @args       = args
      @errors     = []
      @testing    = @options.delete( :test_only )

      # This is your chance to extend the Transition with custom
      # methods, etc so that it models your problem domain.
      apply!( &block ) if block_given?
    end

    def hooks()
      StateFu::Hooks::ALL_HOOKS.map do |arr|
        send(arr[0]).hooks[arr[1]]
      end.flatten
    end

    def current_state
      if accepted?
        :accepted
      else
        current_hook.state rescue :unfired
      end
    end

    def run_hook( hook )

      # FIXME this should have the name of the hook,
      # not the hook itself
      @current_hook = hook
      return if test_only?
      case hook
      when Symbol
        object.send( hook, self )
      when Proc
        if hook.arity == 1
          hook.call( self )
        else
          instance_eval( &hook )
        end
      end
    end

    def halt!( message )
      raise TransitionHalted.new( self, message )
    end

    def fire!
      return false if fired? # no infinite loops please
      @fired = true
      begin
        hooks.each do |hook|
          # begin
            run_hook( hook )
          # rescue TransitionHalted => e
            # ensure the error has all our lovely context
            # e.transition = self
          #   raise e
          # end
        end
        @binding.persister.current_state = @target
        @accepted                        = true
      rescue TransitionHalted => e
        @errors << e
      end
      return !halted?
    end

    def halted?
      !@errors.empty?
    end

    def fired?
      !!@fired
    end

    def testing?
      !!@testing
    end

    def live?
      !testing?
    end

    def accepted?
      !!@accepted
    end

    #
    # Try to give as many options (chances) as possible
    #

    alias_method :obj,            :object
    alias_method :instance,       :object
    alias_method :model,          :object
    alias_method :instance,       :object

    alias_method :destination,    :target
    alias_method :final_state,    :target
    alias_method :to,             :target

    alias_method :original_state, :origin
    alias_method :initial_state,  :origin
    alias_method :from,           :origin

    alias_method :om,             :binding
    alias_method :stateful,       :binding
    alias_method :zen,            :binding
    alias_method :machine,        :binding
    alias_method :zen_machine,    :binding
    alias_method :binding,        :binding
    alias_method :machine,        :binding
    alias_method :present,        :binding

    alias_method :statefully,     :machine
    alias_method :machine,        :machine
    alias_method :workflow,       :machine
    alias_method :zen_machine,    :machine

    alias_method :write? ,        :live?
    alias_method :destructive?,   :live?
    alias_method :real?,          :live?
    alias_method :really?,        :live?
    alias_method :seriously?,     :live?

    alias_method :test?,          :testing?
    alias_method :test_only?,     :testing?
    alias_method :read_only?,     :testing?
    alias_method :only_pretend?,  :testing?
    alias_method :pretend?,       :testing?
    alias_method :dry_run?,       :testing?

  end
end

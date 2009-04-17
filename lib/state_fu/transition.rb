module StateFu

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  class Transition
    include StateFu::Helper
    attr_reader(  :binding,
                  :machine,
                  :origin,
                  :target,
                  :event,
                  :args,
                  :errors,
                  :object,
                  :options,
                  :current_hook_slot,
                  :current_hook )

    attr_accessor :test_only, :args, :options

    def initialize( binding, event, target=nil, *args, &block )
      # ensure event is a StateFu::Event
      if event.is_a?( Symbol ) && e = binding.machine.events[ event ]
        event = e
      end
      raise( ArgumentError, "Not an event: #{event}" ) unless event.is_a?( StateFu::Event )

      # infer target if necessary
      case target
      when StateFu::State # good
      when Symbol
        target = binding.machine.states[ target ] ||
          raise( ArgumentError, "target cannot be determined" )
      when NilClass
        if event.target.is_a?( Array ) && event.target.length == 1
          target = event.target.first
        else
          raise( ArgumentError, "target cannot be determined" )
        end
      else
        raise ArgumentError.new( target.inspect )
      end

      # ensure target is valid for the event
      unless event.target.include?( target )
        raise( StateFu::InvalidTransition.new( binding, event, binding.current_state, target,
                                               "Illegal target #{target} for #{event}" ))
      end

      @options    = args.extract_options!.symbolize_keys!
      @binding    = binding
      @machine    = binding.machine
      @object     = binding.object
      @origin     = binding.current_state
      @target     = target
      @event      = event
      @args       = args
      @errors     = []
      @testing    = @options.delete( :test_only )

      machine.inject_helpers_into( self )

      # do stuff with the transition in a block, if you like
      apply!( &block ) if block_given?
    end

    def check_requirements!
      #
      # TODO - better errors with more info !!
      #

      # ensure requirements are satisfied
      # for the state being exited
      unless origin.exitable_by?( binding )
        raise RequirementError
      end

      # for the state being entered
      unless target.enterable_by?( binding )
        raise RequirementError
      end

      # for the event being fired
      unless event.fireable_by?( binding )
        raise RequirementError
      end
    end

    def hooks_for( element, slot )
      send(element).hooks[slot]
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
      # return if test_only? # TODO - is this what we want?
      case hook
      when Symbol
        unless proc = machine.named_procs[hook]
          # call a normal method on the object
          # passing the transition as the argument
          object.send( hook, self )
        end
      when Proc
        proc = hook
      end
      if proc
        # it's a named proc - check its arity and call it
        if proc.arity == 1
          object.instance_exec( self, &proc )
        else
          instance_eval( &proc )
        end
      end
    end

    def halt!( message )
      raise TransitionHalted.new( self, message )
    end

    def fire!
      return false if fired? # no infinite loops please
      check_requirements!
      @fired = true
      begin
        StateFu::Hooks::ALL_HOOKS.each do |arr|
          @current_hook_slot = arr
          hooks = hooks_for( *arr )
          hooks.each do |hook|
            @current_hook = hook
            run_hook( hook )
          end
        end
        # transition complete
        @binding.persister.current_state = @target
        @current_hook_slot               = nil
        @current_hook                    = nil
        @accepted                        = true
      rescue TransitionHalted => e
        @errors << e
      end
      return accepted?
    end

    def halted?
      !@errors.empty?
    end

    def fired?
      !!@fired
    end

    def testing?
      !!@test_only
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
    alias_method :binding,        :binding
    alias_method :present,        :binding

    alias_method :workflow,       :machine

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

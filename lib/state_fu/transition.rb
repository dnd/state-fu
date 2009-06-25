module StateFu

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  class Transition
    include StateFu::Helper
    include ContextualEval

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
      @binding    = binding
      @machine    = binding.machine
      @object     = binding.object
      @origin     = binding.current_state

      # ensure event is a StateFu::Event
      if event.is_a?( Symbol ) && e = binding.machine.events[ event ]
        event = e
      end
      raise( ArgumentError, "Not an event: #{event}" ) unless event.is_a?( StateFu::Event )

      target = find_event_target( event, target ) || raise( ArgumentError, "target cannot be determined: #{target.inspect}" )

      # ensure target is valid for the event
      unless event.targets.include?( target )
        raise( StateFu::InvalidTransition.new( binding, event, binding.current_state, target,
                                               "Illegal target #{target} for #{event}" ))
      end

      # ensure current_state is a valid origin for the event
      unless event.origins.include?( binding.current_state )
        raise( StateFu::InvalidTransition.new( binding, event, binding.current_state, target,
                                               "Illegal event #{event.name} for current state #{binding.state_name}" ))
      end

      @options    = args.extract_options!.symbolize_keys!
      @target     = target
      @event      = event
      @args       = args
      @errors     = []
      @testing    = @options.delete( :test_only )

      machine.inject_helpers_into( self )

      # do stuff with the transition in a block, if you like
      apply!( &block ) if block_given?
    end

    def requirements
      origin.exit_requirements + target.entry_requirements + event.requirements
    end

    def unmet_requirements
      requirements.reject do |requirement|
        binding.evaluate_requirement_with_transition( requirement, self )
      end
    end

    def evaluate_requirement_message( name )
      msg = machine.requirement_messages[name]
      case msg
      when String, nil
        msg
      when Symbol, Proc
        evaluate_named_proc_or_method( msg, self )
      else
        raise msg.class.to_s
      end
    end

    def unmet_requirement_messages
      unmet_requirements.map do |requirement|
        evaluate_requirement_message( requirement )
      end
    end

    def check_requirements!
      raise RequirementError.new( self, unmet_requirements.inspect ) unless requirements_met?
    end

    def requirements_met?
      unmet_requirements.empty?
    end
    alias_method :valid?, :requirements_met?

    def hooks_for( element, slot )
      send(element).hooks[slot]
    end

    def hooks()
      StateFu::Hooks::ALL_HOOKS.map do |owner, slot|
        [ [owner, slot], send( owner ).hooks[ slot ] ]
      end
    end

    def current_state
      if accepted?
        :accepted
      else
        current_hook.state rescue :unfired
      end
    end

    def run_hook( hook )
      evaluate_named_proc_or_method( hook, self )
    end

    def halt!( message )
      raise TransitionHalted.new( self, message )
    end

    def fire!
      return false if fired? # no infinite loops please
      check_requirements!
      @fired = true
      begin
        StateFu::Hooks::ALL_HOOKS.map do |owner, slot|
          [ [owner, slot], send( owner ).hooks[ slot ] ]
        end.each do |address, hooks|
          owner,slot = *address
          hooks.each do |hook|
            @current_hook_slot = address
            @current_hook      = hook
            run_hook( hook )
          end
          if slot == :entry
            @accepted                        = true
            @binding.persister.current_state = @target
          end
        end
        # transition complete
        @current_hook_slot               = nil
        @current_hook                    = nil
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

    def == other
      case other
      when true
        accepted?
      when false
        !accepted?
      else
        super( other )
      end
    end
  end
end

module StateFu

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  # TODO - make transition evaluate as true if accepted, false if failed, or nil unless fired

  class Transition
    include Applicable
    include Optional

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
    alias_method :arguments, :args
    
    def initialize( binding, event, target=nil, *args, &block )
      @binding    = binding
      @machine    = binding.machine
      @object     = binding.object
      @origin     = binding.current_state
      @args       = args.extend(TransitionArgsArray) #.init(self)
      
      @options    = (args.last.is_a?(Hash)? args.last.symbolize_keys : {} )
      apply!( @options, &block ) if block_given?

      # ensure event is a StateFu::Event
      if event.is_a?(Symbol) && e = binding.machine.events[event]
        event = e
      end
      raise( ArgumentError, "Not an event: #{event}" ) unless event.is_a? Event 

      # ensure we have a target
      target = find_event_target( event, target ) || raise( UnknownTarget.new(self, "target cannot be determined: #{target.inspect} #{self.inspect}"))

      @target     = target
      @event      = event
      @errors     = []
      @testing    = @options.delete(:test_only)
            
      if event.target_for_origin(origin) == target
        # ...
      else
        # ensure target is valid for the event
        unless event.targets.include? target 
          raise InvalidTransition.new self, "Illegal target #{target} for #{event}" 
        end

        # ensure current_state is a valid origin for the event
        unless event.origins.include? origin 
          raise InvalidTransition.new( self, "Illegal event #{event.name} for current state #{binding.state_name}" )
        end
      end 
      
      machine.inject_helpers_into( self )
    end

    def args=(argument_list)
      returning @args = argument_list do |args|
        if args.last.is_a?(Hash)
          apply! args.last
        end
      end 
    end
    
    #
    # Requirements
    #
    
    def requirements
      origin.exit_requirements + target.entry_requirements + event.requirements
    end

    def unmet_requirements(revalidate=false, fail_fast=false) # TODO
      if revalidate
        return @unmet_requirements if @unmet_requirements
      else
        @unmet_requirements = nil
      end
      result = requirements.uniq.inject([]) do |unmet, requirement|
        next if fail_fast && !unmet.empty?
        unmet << requirement unless evaluate(requirement)
        unmet
      end
      @unmet_requirements = result if (!fail_fast || unmet_requirements.length <= 1)
      result
    end
    
    def first_unmet_requirement(revalidate=false)
      unmet_requirements(revalidate, fail_fast=true)[0]
    end

    def unmet_requirement_messages(revalidate=false, fail_fast=false) # TODO
      unmet_requirements(revalidate, fail_fast).map do |requirement|
        evaluate_requirement_message requirement 
      end.extend MessageArray
    end
    
    def requirement_errors(revalidate=false, fail_fast=false)
      Hash[ unmet_requirements(revalidate, fail_fast).
        map { |requirement| [requirement, evaluate_requirement_message(requirement)] }]
    end

    def first_unmet_requirement_message(revalidate=false)
      unmet_requirement_messages(revalidate, fail_fast=true)[0]
    end

    def check_requirements!(revalidate=false, fail_fast=true) # TODO
      raise RequirementError.new( self, unmet_requirement_messages.inspect ) unless requirements_met?(revalidate, fail_fast)
    end

    def requirements_met?(revalidate=false, fail_fast=false) # TODO
      unmet_requirements(revalidate, fail_fast).empty?
    end
    alias_method :valid?, :requirements_met?
    
    #
    # Hooks
    #
    def hooks_for(element, slot)
      send(element).hooks[slot]
    end

    def hooks
      StateFu::Hooks::ALL_HOOKS.map do |owner, slot|
        [ [owner, slot], send(owner).hooks[slot] ]
      end
    end

    def run_hook hook 
      evaluate hook 
    end



    #
    #
    #

    # halt a transition with a message
    # can be used to back out of a transition inside eg a state entry hook
    def halt! message 
      raise TransitionHalted.new( self, message )
    end

    #
    #
    #
    
    # actually fire the transition
    def fire!
      raise TransitionAlreadyFired.new(self) if fired?
      # return false if fired? # no infinite loops please
      check_requirements!
      @fired = true
      begin
        # duplicated: see #hooks method
        StateFu::Hooks::ALL_HOOKS.map do |owner, slot|
          [ [owner, slot], send(owner).hooks[slot] ]
        end.each do |address, hooks|
          Logger.info("running #{address.inspect} hooks for #{object.class} #{object}")
          owner,slot = *address
          hooks.each do |hook|
            Logger.info("running hook #{hooks} for #{object.class} #{object}")
            @current_hook_slot = address
            @current_hook      = hook
            run_hook hook 
          end
          if slot == :entry
            @accepted                        = true
            @binding.persister.current_state = @target
            Logger.info("State is now :#{@target.name} for #{object.class} #{object}")
          end
        end
        # transition complete
        @current_hook_slot               = nil
        @current_hook                    = nil
      rescue TransitionHalted => e
        Logger.info("Transition halted for #{object.class} #{object}: #{e.inspect}")
        @errors << e
      end
      return accepted?
    end
    
    #
    # It can pretend it's a hash; so the transition makes a good argument to be
    # passed to methods.
    # 
    include Enumerable

    def each *a, &b 
      options.each *a, &b 
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
    alias_method :complete?, :accepted?
    
    def current_state
      binding.current_state
    end
   
    #
    # give as many choices as possible
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

    alias_method :test?,          :testing?
    alias_method :test_only?,     :testing?
    alias_method :read_only?,     :testing?
    alias_method :only_pretend?,  :testing?
    alias_method :dry_run?,       :testing?

    # an accepted transition == true
    # an unaccepted transition == false
    # same for === (for case equality)
    def == other
      case other
      when true
        accepted?
      when false
        !accepted?
      when State, Symbol
        current_state == other.to_sym
      when Transition
        inspect == other.inspect
      else
        super( other )
      end
    end

    # display nice and short
    def inspect
      s = self.to_s
      s = s[0,s.length-1]
      s << " event=#{event.to_sym.inspect}" if event
      s << " origin=#{origin.to_sym.inspect}" if origin
      s << " target=#{target.to_sym.inspect}" if target
      s << " args=#{args.inspect}" if args
      s << ">"
      s
    end

    private

    def executioner
      @executioner ||= Executioner.new( self ) do |ex|
        machine.inject_helpers_into( ex )
        machine.inject_methods_into( ex )
      end
    end

    def evaluate(method_name_or_proc)
      executioner.evaluate(method_name_or_proc)
    end

    def evaluate_requirement_message( name )
      msg = machine.requirement_messages[name]
      case msg
      when String
        msg
      when nil
        name
      when Symbol, Proc
        evaluate msg 
      else
        raise msg.class.to_s
      end
    end

    def find_event_target( evt, tgt )
      case tgt
      when StateFu::State
        tgt
      when Symbol
        binding && binding.machine.states[ tgt ] # || raise( tgt.inspect )
      when NilClass
        evt.respond_to?(:target) && evt.target
      else
        raise ArgumentError.new( "#{tgt.class} is not a Symbol, StateFu::State or nil (#{evt})" )
      end
    end

  end
end

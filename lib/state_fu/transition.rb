module StateFu

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  # TODO - make transition evaluate as true if accepted, false if failed, or nil unless fired

  class Transition
    include Applicable
    include HasOptions

    attr_reader :binding,
                :machine,
                :origin,
                :target,
                :event,
                :args,
                :errors,
                :object,
                :current_hook_slot,
                :current_hook 

    alias_method :arguments, :args
    
    def initialize( binding, event, target=nil, *argument_list, &block )
      # ensure we have an Event
      event = binding.machine.events[event] if event.is_a?(Symbol)
      raise( ArgumentError, "Not an event: #{event}" ) unless event.is_a? Event 

      @binding    = binding
      @machine    = binding.machine
      @object     = binding.object
      @origin     = binding.current_state
            
      self.args= argument_list
      apply!(argument_list, &block ) 
      
      # ensure we have a target
      target = find_event_target( event, target ) || raise( UnknownTarget.new(self, "target cannot be determined: #{target.inspect} #{self.inspect}"))

      @target     = target
      @event      = event
      @errors     = []
            
      if event.target_for_origin(origin) == target
        # it's a "sequence"
        # which is a hacky way of emulating simpler state machines with
        # state-local events - and in which case, the targets & origins are
        # valid. Quite likely this notion will be removed in time.
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

    def args=(args)      
      @args = args.extend(TransitionArgsArray).init(self)    
      apply!(args) if args.last.is_a?(Hash) unless options.nil?
    end
    
    def with(*args)
      self.args = args      
    end
    
    #
    # Requirements
    #
    
    def requirements
      origin.exit_requirements + target.entry_requirements + event.requirements
    end

    def unmet_requirements(revalidate=false, fail_fast=false) 
      if revalidate
        @unmet_requirements = nil
      else
        return @unmet_requirements if @unmet_requirements
      end
      result = requirements.uniq.inject([]) do |unmet, requirement|
        next if fail_fast && !unmet.empty?
        unmet << requirement unless evaluate(requirement)
        unmet
      end
      @unmet_requirements = result if (!fail_fast || unmet_requirements.length != 1)
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
    alias_method :error_messages, :unmet_requirement_messages
    
    def requirement_errors(revalidate=false, fail_fast=false)
      unmet_requirements(revalidate, fail_fast).
        map { |requirement| [requirement, evaluate_requirement_message(requirement)]}.
        to_h
    end

    def first_unmet_requirement(revalidate=false)
      unmet_requirements(revalidate, fail_fast=true)[0]
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
    def fire!(*arguments) # block? 
      raise TransitionAlreadyFired.new(self) if fired?
      self.args = arguments unless arguments.empty?
            
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
      self
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

    def accepted?
      !!@accepted
    end
    alias_method :complete?, :accepted?
    
    def current_state
      binding.current_state
    end
    
    def destination
      [event, target].map(&:to_sym)
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
      s << " options=#{options.inspect}" if options
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
        binding && binding.machine.states[ tgt ] 
      when NilClass
        evt.respond_to?(:target) && evt.target
      else
        raise ArgumentError.new( "#{tgt.class} is not a Symbol, StateFu::State or nil (#{evt})" )
      end
    end

  end
end

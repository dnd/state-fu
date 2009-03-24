module Zen

  # A 'context' class, created when an event is fired, or needs to be
  # validated.
  #
  # This is what gets yielded to event hooks; it also gets attached
  # to any TransitionHalted exceptions raised.

  class Transition
    include Zen::Helper
    attr_reader(  :meditation,
                  :origin,
                  :target,
                  :event,
                  :args,
                  :errors,
                  :object,
                  :options,
                  :current_hook )

    attr_accessor :only_pretend

    def initialize( meditation, origin, target, event, *args, &block )
      apply!( args ) # handle options
      @meditation = meditation
      @object     = meditation.object
      @origin     = origin
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
      [ origin.hooks,
        event.hooks,
        target.hooks ].sort
    end

    def current_state
      if accepted?
        :accepted
      else
        current_hook.state rescue :unfired
      end
    end

    def fire!
      return false if fired? # no infinite loops please
      @fired = true
      begin
        hooks.each do |hook|
          @current_hook = hook
          begin
            if pretending?
              current_hook.test( self )
            else
              current_hook.apply!( self )
            end
          rescue TransitionHalted => e
            # ensure the error has all our lovely context
            e.transition = self
            raise e
          end
        end
        @accepted = true
      rescue TransitionHalted => e
        #
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

    alias_method :disciple,       :object
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

    alias_method :om,             :meditation
    alias_method :stateful,       :meditation
    alias_method :zen,            :meditation
    alias_method :koan,           :meditation
    alias_method :zen_koan,       :meditation
    alias_method :meditation,     :meditation
    alias_method :machine,        :meditation
    alias_method :present,        :meditation

    alias_method :statefully,     :koan
    alias_method :machine,        :koan
    alias_method :workflow,       :koan
    alias_method :zen_koan,       :koan

    alias_method :write? ,        :live?
    alias_method :destructive?,   :live?
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

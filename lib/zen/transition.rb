module Zen
  class Transition

    attr_reader :meditation, :origin, :target, :event, :args, :errors, :object, :options
    attr_accessor :only_pretend, :exit_on_failure

    def initialize( meditation, origin, target, event, *args, &block )
      @options    = args.extract_options!.symbolize_keys!
      @meditation = meditation
      @object     = meditation.object
      @origin     = origin
      @target     = target
      @event      = event
      @args       = args
      @block      = block if block_given?
      @errors     = []

      @only_pretend    = @options.delete(:only_pretend)
      @exit_on_failure = @options.delete(:exit_on_failure)
    end
    alias_method :disciple, :object
    alias_method :model,    :object
    alias_method :instance, :object

    def hooks()
      meditation # ... map .. flatten .. etc
    end

    def fire!
      return false if fired?
      @fired = true
      hooks = collect_hooks()
      begin
        hooks().each do |hook|
          begin
            if only_pretend?
              hook.test( self )
            else
              hook.apply!( self )
            end
            @accepted = true
          rescue TransitionHalted => e
            @errors << e
            if exit_on_failure?
              raise e
            else
              @only_pretend = true # no more actions with side-effects
            end
          end # rescue
        end # begin
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

    def only_pretend?
      !!@only_pretend
    end

    def exit_on_failure?
      !!@exit_on_failure
    end

    def accepted?
      !!@accepted
    end

  end
end

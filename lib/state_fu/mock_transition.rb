module StateFu
  class MockTransition
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
      @options    = args.extract_options!.symbolize_keys!
      if @binding = binding
        @machine = binding.machine       rescue nil
        @object  = binding.object        rescue nil
        @origin  = binding.current_state rescue nil
      end
      @event   = event
      @target  = find_event_target( event, target )
      @args    = args
      @errors  = []
      @testing = true

      machine.respond_to?(:inject_helpers_into) && machine.inject_helpers_into( self )
      apply!( &block ) if block_given?
    end

  end
end

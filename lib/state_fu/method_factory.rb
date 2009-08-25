module StateFu
  # This class is responsible for defining methods at runtime.
  #
  # TODO: all events, simple or complex, should get the same method signature
  # simple events will be called as:  event_name! nil,    *args
  # complex events will be called as: event_name! :state, *args
  
  class MethodFactory

    # An instance of MethodFactory is created to define methods on a specific StateFu::Binding, and
    # the object it is bound to.
    #
    # During the initializer, it will call define_event_methods_on(the binding), which installs
    #
    def initialize( _binding )
      # store @binding in a local variable so it's accessible within
      # the closures below (for define_singleton_method ).

      # i.e, we're embedding a reference to @binding inside the method
      @binding = _binding      
      @defs    = {}

      @binding.machine.states.each do |state|
        @defs[:"#{state.name}?"] = lambda { _binding.current_state.name == state.name }
      end
      
      # method definitions for simple events (only one possible target)
      @binding.machine.events.each do |event|
        @defs[event.name]           = lambda \
        {|*args| _binding._event_method :get_transition,   event, args.shift, *args }
        @defs[:"can_#{event.name}?"] = lambda \
          {|*args| _binding._event_method :query_transition, event, args.shift, *args }
        @defs[:"#{event.name}!"]     = lambda \
          {|*args| _binding._event_method :fire_transition,  event, args.shift, *args }
        
        #if !event.targets.blank? # && event.targets.length > 1
        event.targets.each do |target_state|
          method_name = "#{event.name}_to_#{target_state.name}"

          # object.event_name [:target], *arguments
          #
          # returns a new transition. Will raise an InvalidTransition if 
          # it is not given arguments which result in a valid combination
          # of event and target state being deducted.
          #
          # object.event_name suffices without any arguments if the event 
          # has only one possible target, or only one valid target for 
          
          # object.event_name! [:target], *arguments
          #
          # as per the method above, except that it also
          
          @defs[method_name.to_sym]     = lambda \
            {|*args| _binding._event_method :get_transition,   event, target_state, *args }
            
          # object.event_name! [:]
          @defs[:"can_#{method_name}?"] = lambda \
            {|*args| _binding._event_method :query_transition, event, target_state, *args }
            
          @defs[:"#{method_name}!"]     = lambda \
            {|*args| _binding._event_method :fire_transition,  event, target_state, *args }          
            
        end unless event.targets.nil?
      end    
    end

    #
    # Class Methods
    #

    # This should be called once per class using StateFu. It aliases and redefines
    # method_missing for the class.
    #
    # Note this happens when a machine is first bound to the class,
    # not when StateFu is included.

    def self.prepare_class( klass )
      raise caller.inspect
      self.define_once_only_method_missing( klass )
    end # prepare_class

    # When triggered, method_missing will first call state_fu!,
    # instantating all bindings & installing their attendant
    # MethodFactories, then check if the object now responds to the
    # missing method name; otherwise it will call the original
    # method_missing.
    #
    # method_missing will then revert to its original implementation.
    #
    # The purpose of all this is to allow dynamically created methods
    # to be called, without worrying about whether they have been
    # defined yet, and without incurring the expense of loading all
    # the object's StateFu::Bindings before they're likely to be needed.
    #
    # Note that if you redefine method_missing on your StateFul
    # classes, it's best to either do it before you include StateFu,
    # or thoroughly understand what's happening in
    # MethodFactory#define_once_only_method_missing.

    def self.define_once_only_method_missing( klass )
      raise ArgumentError.new(klass.to_s) unless klass.is_a?(Class)      
      
      klass.class_eval do                
        return false if @_state_fu_prepared
        @_state_fu_prepared = true

        alias_method(:method_missing_before_state_fu, :method_missing) # if defined?(:method_missing, true)

        def method_missing(method_name, *args, &block)
          # invoke state_fu! to ensure event, etc methods are defined
          begin            
            state_fu! unless defined? initialize_state_fu!            
          rescue NoMethodError => e
            raise e
          end
          
          # reset method_missing for this instance
          class << self; self; end.class_eval do
            alias_method :method_missing, :method_missing_before_state_fu              
          end
        
          # call the newly defined method, or the original method_missing
          if respond_to?(method_name, true) 
            # it was defined by calling state_fu!, which instantiated bindings
            # for its state machines, which defined singleton methods for its
            # states & events when it was constructed.
            __send__( method_name, *args, &block )
          else 
            # call the original method_missing (method_missing_before_state_fu)
            method_missing( method_name, *args, &block )
          end
        end # method_missing
      end # class_eval
    end # define_once_only_method_missing

    # Define the same helper methods on the StateFu::Binding and its
    # object.  Any existing methods will not be tampered with, but a
    # warning will be issued in the logs if any methods cannot be defined.
    def install!
      define_event_methods_on( @binding )
      define_event_methods_on( @binding.object )
    end

    #
    # For each event, on the given object, define three methods.
    # - The first method is the same as the event name.
    #   Returns a new, unfired transition object.
    # - The second method has a "?" suffix.
    #   Returns true if the event can be fired.
    # - The third method has a "!" suffix.
    #   Creates a new Transition, fires and returns it once complete.
    #
    # The arguments expected depend on whether the event is "simple" - ie,
    # has only one possible target state.
    #
    # All simple event methods pass their entire argument list
    # directly to transition.  These arguments can be accessed inside
    # event hooks, requirements, etc by calling Transition#args.
    #
    # All complex event methods require their first argument to be a
    # Symbol containing a valid target State's name, or the State
    # itself.  The remaining arguments are passed into the transition,
    # as with simple event methods.
    #
    def define_event_methods_on( obj )
      @defs.each do |method_name, method_body|
        define_singleton_method( obj, method_name, &method_body)
      end
    end # define_event_methods_on

    def define_singleton_method( object, method_name, &block )
      MethodFactory.define_singleton_method object, method_name, &block
    end

    # define a a method on the metaclass of the given object. The
    # resulting "singleton method" will be unique to that instance,
    # not shared by other instances of its class.
    #
    # This allows us to embed a reference to the instance's unique
    # binding in the new method.
    #
    # existing methods will never be overwritten.

    def self.define_singleton_method( object, method_name, options={}, &block )
      if object.respond_to?(method_name, true) 
        msg = !options[:force]
        Logger.info "Existing method #{method(method_name) rescue [method_name].inspect} "\
          "for #{object.class} #{object} "\
          "#{options[:force] ? 'WILL' : 'won\'t'} "\
          "be overwritten."
      else
        metaclass = class << object; self; end
        metaclass.class_eval do
          define_method( method_name, &block )
        end
      end
    end
    alias_method :define_singleton_method, :define_singleton_method

  end # class MethodFactory
end # module StateFu



module StateFu
  # This class is responsible for defining methods at runtime.
  #
  #
  #
  #
  class MethodFactory

    # An instance of MethodFactory is created to define methods on a specific StateFu::Binding, and
    # the object it is bound to.
    #
    # During the initializer, it will call define_event_methods_on(the binding), which installs
    #
    def initialize( _binding )
      @binding = _binding
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
      unless klass.is_a?(Class)
        raise NotImplementedError.new("singleton machines are not yet supported")
      end
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
      return if klass.instance_methods.map(&:to_sym).include? :method_missing_before_state_fu
      klass.class_eval do
        alias_method :method_missing_before_state_fu, :method_missing
        def method_missing( method_name, *args, &block )
          # invoke state_fu! to define methods
          state_fu!
          # reset method_missing for this instance
          # more for tidy stack traces than anything else
          # TODO - benchmark with presence / absence of this reset
          metaclass = class << self; self; end
          metaclass.instance_eval do
            alias_method :method_missing, :method_missing_before_state_fu
          end
          # call the newly defined method, or the original method_missing
          if respond_to?( method_name ) # it was defined by calling state_fu!
            send( method_name, *args, &block )
          else
            method_missing_before_state_fu( method_name, *args, &block )
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
      # store @binding in a local variable so it's accessible within
      # the closures below (for define_singleton_method ).

      # i.e, we're embedding a reference to @binding inside the method

      _binding        = @binding
      simple, complex = @binding.machine.events.partition(&:simple? )

      # method definitions for simple events (only one possible target)
      simple.each do |event|

        # obj.event_name( *args )
        # returns a new transition
        method_name = event.name
        define_singleton_method( obj, method_name ) do |*args|
          _binding.transition( event, *args )
        end

        # obj.event_name?()
        # true if the event is fireable? (ie, requirements met)
        method_name = "#{event.name}?"
        define_singleton_method( obj, method_name ) do
          _binding.fireable?( event )
        end

        # obj.event_name!( *args )
        # creates, fires and returns a transition
        method_name = "#{event.name}!"
        define_singleton_method( obj, method_name) do |*args|
          _binding.fire!( event, *args )
        end
      end # simple
      # method definitions for complex events (target must be specified)
      complex.each do |event|
        # obj.event_name( target, *args )
        # returns a new transition
        define_singleton_method( obj, event.name ) do |target, *args|
          _binding.transition( [event, target], *args )
        end

        # obj.event_name?( target )
        # true if the event is fireable? (ie, requirements met)
        method_name = "#{event.name}?"
        define_singleton_method( obj, method_name ) do |target, *args|
          _binding.fireable?( [event, target], *args )
        end

        # obj.event_name!( target, *args )
        # creates, fires and returns a transition
        method_name = "#{event.name}!"
        define_singleton_method( obj, method_name ) do |target, *args|
          _binding.fire!( [event, target], *args )
        end
      end # complex
    end # define_event_methods_on

    # define a a method on the metaclass of the given object. The
    # resulting "singleton method" will be unique to that instance,
    # not shared by other instances of its class.
    #
    # This allows us to embed a reference to the instance's unique
    # binding in the new method.
    #
    # existing methods will never be overwritten.

    def define_singleton_method( object, method_name, &block )
      if object.respond_to?( method_name )
        Logger.info("Existing method #{method_name} for #{object.class} will NOT be overwritten.")
      else
        metaclass   = class << object; self; end
        metaclass.class_eval do
          define_method( method_name, &block )
        end
      end
    end
    alias_method :define_singleton_method, :define_singleton_method

  end # class MethodFactory
end # module StateFu

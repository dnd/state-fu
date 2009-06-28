module StateFu
  class MethodFactory

    def initialize( _binding )
      @binding = _binding
      define_event_methods_on( _binding )
    end

    def install!
      define_event_methods_on( @binding.object )
    end

    def self.define_once_only_method_missing( klass )
      return if ( klass.instance_methods ).map(&:to_sym).include?( :method_missing_before_state_fu )
      klass.class_eval do
        alias_method :method_missing_before_state_fu, :method_missing
        def method_missing( method_name, *args, &block )
          # invoke state_fu! to define methods
          state_fu!
          # reset method_missing for this instance
          # more for tidy stack traces than anything else
          metaclass = class << self; self; end
          metaclass.instance_eval do
            alias_method :method_missing, :method_missing_before_state_fu
          end
          # call the newly defined method or the original method_missing
          if respond_to?( method_name )
            send( method_name, *args, &block )
          else
            method_missing_before_state_fu( method_name, *args, &block )
          end
        end # method_missing
      end # class_eval
    end

    # ensure the methods are available before calling state_fu
    def self.prepare_class( klass )
      self.define_once_only_method_missing( klass )
    end # prepare_class

    def define_method_on_metaclass( object, method_name, &block )
      return false if object.respond_to?( method_name )
      metaclass   = class << object; self; end
      metaclass.class_eval do
        define_method( method_name, &block )
      end
    end

    def define_event_methods_on( obj )
      _binding        = @binding
      simple, complex = @binding.machine.events.partition(&:simple? )

      # method definitions for simple events (only one possible target)
      simple.each do |event|
        # obj.event_name( *args )
        # returns a new transition
        method_name = event.name
        define_method_on_metaclass( obj, method_name ) do |*args|
          _binding.transition( event, *args )
        end

        # obj.event_name?()
        # true if the event is fireable? (ie, requirements met)
        method_name = "#{event.name}?"
        define_method_on_metaclass( obj, method_name ) do
          _binding.fireable?( event )
        end

        # obj.event_name!( *args )
        # creates, fires and returns a transition
        method_name = "#{event.name}!"
        define_method_on_metaclass( obj, method_name ) do |*args|
          _binding.fire!( event, *args )
        end
      end

      # method definitions for complex events (target must be specified)
      complex.each do |event|
        # obj.event_name( target, *args )
        # returns a new transition
        define_method_on_metaclass( obj, event.name ) do |target, *args|
          _binding.transition( [event, target], *args )
        end

        # obj.event_name?( target )
        # true if the event is fireable? (ie, requirements met)
        method_name = "#{event.name}?"
        define_method_on_metaclass( obj, method_name ) do |target, *args|
          _binding.fireable?( [event, target], *args )
        end

        # obj.event_name!( target, *args )
        # creates, fires and returns a transition
        method_name = "#{event.name}!"
        define_method_on_metaclass( obj, method_name ) do |target, *args|
          _binding.fire!( [event, target], *args )
        end

      end
    end
  end
end

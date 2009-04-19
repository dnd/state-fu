module StateFu
  class MethodFactory

    def initialize( binding )
      @binding = binding
      define_event_methods_on( binding )
    end

    def install!
      define_event_methods_on( @binding.object )
    end

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
        define_method_on_metaclass( obj, method_name ) do |target|
          _binding.fireable?( [event, target] )
        end

        # obj.event_name!( target, *args )
        # creates, fires and returns a transition
        method_name = "#{event.name}!"
        define_method_on_metaclass( obj, method_name ) do |target,*args|
          _binding.fire!( [event, target], *args )
        end

      end
    end
  end
end

module StateFu
  class MethodFactory

    def initialize( binding )
      @binding = binding
    end

    def metaclass
      class << @binding; self; end
    end

    def install!
      define_methods_on_object!
      define_methods_on_binding!
    end

    #
    # object methods
    #

    def define_methods_on_object! # the stateful instance
      simple, complex = @binding.machine.events.partition(&:simple? )
      simple.each do |event|
        define_simple_event_trigger_method_on_object( event )
        define_simple_event_query_method_on_object( event )
      end
      complex.each do |event|

      end
    end

    def define_simple_event_trigger_method_on_object( event )
      binding     = @binding
      define_method_on_metaclass( @binding.object,
                                  "#{event.name}!",
                                  &lambda { |*args| binding.fire!( event, *args ) } )
    end

    def define_simple_event_query_method_on_object( event )
      binding     = @binding
      define_method_on_metaclass( @binding.object,
                                  "#{event.name}?",
                                  &lambda { |*args| binding.fireable?( event ) } )
    end

    #
    # binding methods
    #

    def define_methods_on_binding!
      @binding.machine.events.select(&:simple? ).each do |e|
        define_simple_event_trigger_method_on_binding( e )
        define_simple_event_query_method_on_binding( e )
      end
    end

    def define_simple_event_trigger_method_on_binding( event )
      define_method_on_metaclass( @binding,
                                  "#{event.name}!",
                                  &lambda { |*args| fire!( event, *args ) } )
    end

    def define_simple_event_query_method_on_binding( event )
      define_method_on_metaclass( @binding,
                                  "#{event.name}?",
                                  &lambda { |*args| fireable?( event, *args ) } )
    end

    def define_method_on_metaclass( object, method_name, &block )
      return false if object.respond_to?( method_name )
      metaclass   = class << object; self; end
      metaclass.class_eval do
        define_method( method_name, &block )
      end
    end

  end
end

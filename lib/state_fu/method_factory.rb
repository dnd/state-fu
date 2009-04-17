module StateFu
  class MethodFactory

    def initialize( binding )
      @binding = binding
    end

    def metaclass
      class << @binding; self; end
    end

    def install_simple_event_methods_on_object! # the stateful instance
      @binding.machine.events.select(&:simple? ).each do |e|
        define_simple_event_method_on_object( e )
      end
    end

    def define_simple_event_method_on_object( event )
      binding     = @binding
      method_name = "#{event.name}!"
      metaclass   = class << @binding.object; self; end
      metaclass.class_eval do
        define_method method_name do |*args|
          binding.fire!( event, *args )
        end
      end
    end

    def install_simple_event_methods_on_binding!
      @binding.machine.events.select(&:simple? ).each do |e|
        define_simple_event_method_on_binding( e )
      end
    end

    def define_simple_event_method_on_binding( event )
      method_name = "#{event.name}!"
      metaclass   = class << @binding; self; end
      metaclass.class_eval do
        define_method method_name do |*args|
          fire!( event, *args )
        end
      end
    end

  end
end

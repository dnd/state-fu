=begin
module Zen
  class Binding
#    include Zen::Helper

    def self.instruct!( klass, koan, method_name, field_name = nil )
      method_name  = method_name.to_sym
      field_name ||= method_name.to_s.downcase.tr(' ', '_') + "_state"
      field_name   = field_name.to_sym
      if Zen::Space.class_koans[klass][method_name]
        raise("#{klass} already knows a Koan by the name #{method_name}.")
      else
        Zen::Space.class_koans[klass][method_name] = koan
      end
      # Define a method to return a meditation on the Koan,
      # through which it may be enlightened
      # Not used in the default case, where object.om suffices.
      _ivar_name    = "@_#{method_name}"
      klass.class_eval do
        unless _klass.respond_to?( _method_name ) || _method_name == Zen::DEFAULT_KOAN
          mc.send( :define_method, _method_name ) do
            send( Zen::DEFAULT_KOAN, _method_name )
          end
        end
      end
      # TODO add persister here
    end
  end
end

__END__

    def bind_to_class!
      # define these here so they're available in the closure below
      _binding      = self
      _ivar_name    = instance_variable_name_for_binding()
      _method_name  = @method_name
      _klass        = @klass

      @klass.class_eval do
        mc = class << _klass; self; end
        unless _klass.respond_to?( :koan )
          mc.send( :define_method, :koan ) do
            _binding
          end
        end

        # Define a class method to return the bound Zen::Binding instance;
        # in the default case, calling Klass.zen() yields Klass's
        # default Zen::Binding ( also, Zen::Space.class_koans[ klass ].default )
        unless _klass.respond_to?( _method_name ) || _method_name == Zen::DEFAULT_KOAN
          mc.send( :define_method, _method_name ) do
            # _binding
            send(Zen::DEFAULT_KOAN, _method_name )
          end
        end

        # this works, but there's a 10x simpler way to do it
        # see InstanceMethods.om
        #
        # <facepalm />

        # Define an instance method so the object can meditate on the Koan.
        # unless instance_methods.include?( _method_name )
        #   define_method( _method_name ) do
        #     # use an instance variable to cache the reference
        #     instance_variable_get( _ivar_name ) ||
        #       # construct a new Meditation, through which the object
        #       # instance (self) can follow the Koan on the path to Zen.
        #       instance_variable_set( _ivar_name,
        #                              Zen::Meditation.new( _binding, self ) )
        #
        #   end
        # end

      end
    end

  end
end
=end

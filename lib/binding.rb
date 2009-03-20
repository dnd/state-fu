module Zen
  #
  #
  class Binding
    include Zen::Helper

    @@after_initialize = []

    def self.after_initialize( method_to_call )
      @@after_initialize << method_to_call
    end

    # ensure you require 'active_record' first if you're going to use it.
    if Object.const_defined?( 'ActiveRecord' )
      include Zen::Persistence::ActiveRecord
    end

    attr_reader :klass, :koan, :method_name, :options

    def initialize( klass, method_name, koan, options=DEFAULT_OPTIONS )
      options.symbolize_keys!
      @klass       = klass
      @koan        = koan
      @method_name = method_name.to_sym
      @field_name  = options[:field_name] # a symbol / string, or nil (default)
      @meta        = options.delete(:meta)

      field_name=( field_name )

      if Zen::Space.bindings[@klass][@method_name]
        raise("#{klass} already knows this koan as #{@method_name}.")
      else
        Zen::Space.bindings[@klass][@method_name] = self
      end
      bind!
      @@after_initialize.each { |sym| send(sym) if method(sym) }
    end

    def field_name=( fn )
      fn          = @method_name if fn.blank?
      @field_name = fn.to_s.downcase.tr(' ', '_') + "_state"
    end

    protected

    def instance_variable_name_for_binding
      "@#{method_name}"
    end

    def bind!
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


module StateFu
  class Binding

    attr_reader :object, :machine, :method_name, :persister

    def initialize( machine, object, method_name )
      @machine          = machine
      @object        = object
      @method_name   = method_name

      field_name     = StateFu::FuSpace.field_names[object.class][@method_name]
      @persister     = StateFu::Persistence.for( self, field_name )
      Logger.info( "Persister added: #@persister ")
    end
    alias_method :machinist, :object
    alias_method :model,    :object
    alias_method :instance, :object

    def field_name
      persister.field_name
    end

    def current_state
      persister.current_state
    end

  end

end

module Zen
  class Meditation

    attr_reader :object, :koan, :method_name, :persister

    def initialize( koan, object, method_name )
      @koan          = koan
      @object        = object
      @method_name   = method_name

      field_name     = Zen::Space.field_names[object.class][@method_name]
      @persister     = Zen::Persistence.for( self, field_name )
      Logger.info( "Persister added: #@persister ")
    end
    alias_method :disciple, :object
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

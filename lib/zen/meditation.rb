module Zen
  class Meditation

    attr_reader :disciple, :koan, :method_name, :persister

    def initialize( koan, object, method_name )
      @koan          = koan
      @disciple      = object
      @method_name   = method_name

      field_name     = Zen::Space.field_names[object.class][@method_name]
      @persister     = Zen::Persistence.for( self, field_name )
      Logger.info( "Persister added: #@persister ")
    end

    def field_name
      persister.field_name
    end

    def current_state
      persister.current_state
    end

  end

end

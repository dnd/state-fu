module Zen
  class Meditation

    attr_reader :disciple, :koan, :method_name, :field_name

    def initialize( koan, object, method_name )
      @koan        = koan
      @disciple    = object
      @method_name = method_name
      @field_name  = Zen::Space.field_names[object.class][@method_name]
    end

    def current_state
      @current_state ||= koan.initial_state
    end

  end

end

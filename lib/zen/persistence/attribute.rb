module Zen
  module Persistence
    class Attribute < Zen::Persistence::Base
      private

      # TODO
      #  - exception handling
      #  - performance tuning
      #  - bling

      def read_attribute
        unless object.respond_to?( field_name )
          Logger.info "Adding attr_accessor :#{field_name} for #{object.class}"
          object.class.send( :attr_accessor, field_name )
        end
        string = object.send( field_name )
        Logger.info "Read attribute #{field_name}, got #{string} for #{object}"
        string
      end

      def write_attribute( string_value )
        writer_method = "#{field_name}="
        Logger.info "Writing attribute #{field_name} -> #{string_value} for #{object}"
        object.send( writer_method, string_value )
      end

    end
  end
end

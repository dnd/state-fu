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
          object.class.send( :attr_accessor, field_name )
        end
        object.send( field_name )
      end

      def write_attribute( string_value )
        writer_method = "#{field_name}="
        object.send( writer_method, string_value )
      end

    end
  end
end

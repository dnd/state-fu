module StateFu
  module Persistence
    class ActiveRecord < StateFu::Persistence::Base
      private

      # We already checked that they exist, or we'd be using the
      # Attribute version, so just do the simplest thing we can.

      def read_attribute
        object.send( :read_attribute, field_name )
      end

      def write_attribute( string_value )
        object.send( :write_attribute, field_name, string_value )
      end

    end
  end
end

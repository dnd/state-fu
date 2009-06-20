module StateFu
  module Persistence
    class RelaxDB < StateFu::Persistence::Base

      def self.prepare_field( klass, field_name )
        _field_name = field_name
        #puts "relaxdb.before_save?"
      end

      private

      def read_attribute
        #object.send( :read_attribute, field_name )
      end

      def write_attribute( string_value )
        #object.send( :write_attribute, field_name, string_value )
      end

    end
  end
end


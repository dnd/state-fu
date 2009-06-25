module StateFu
  module Persistence
    class ActiveRecord < StateFu::Persistence::Base

      def self.prepare_field( klass, field_name )
        _field_name = field_name
        Logger.debug("Preparing ActiveRecord field #{klass}.#{field_name}")
        klass.send :before_save, :state_fu!
        # validates_presence_of _field_name
      end

      private

      # We already checked that they exist, or we'd be using the
      # Attribute version, so just do the simplest thing we can.

      def read_attribute
        Logger.debug "Read attribute #{field_name}, got #{object.send(:read_attribute,field_name)} for #{object.inspect}"
        object.send( :read_attribute, field_name )
      end

      def write_attribute( string_value )
        Logger.debug "Write attribute #{field_name} to #{string_value} for #{object.inspect}"
        object.send( :write_attribute, field_name, string_value )
      end

    end
  end
end

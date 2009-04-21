module StateFu
  module Persistence
    class Attribute < StateFu::Persistence::Base

      def self.prepare_field( klass, field_name )
        # ensure getter exists
        unless klass.instance_methods.include?( field_name )
          Logger.info "Adding attr_reader :#{field_name} for #{klass}"
          _field_name = field_name
          klass.class_eval do
            private
            attr_reader _field_name
          end
        end

        # ensure setter exists
        unless Klass.instance_methods.include?( "#{field_name}=" )
          Logger.info "Adding attr_writer :#{field_name}= for #{klass}"
          _field_name = field_name
          klass.class_eval do
            private
            attr_writer _field_name
          end
        end
      end

      private

      # Read / write our strings to a plain old instance variable
      # Define it if it doesn't exist the first time we go to read it

      def read_attribute
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

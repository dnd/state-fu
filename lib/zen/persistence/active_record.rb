module Zen
  module Persistence
    class ActiveRecord < Zen::Persistence::Base
      private

      def read_attribute
        object.send( :read_attribute, field_name )
        # raise "Abstract method! override me"
      end

      def write_attribute( string_value )
        object.send( :write_attribute, field_name, string_value )
        # raise "Abstract method! override me"
      end

    end
  end
end

module Zen

  class InvalidStateName < Exception
  end

  module Persistence
    class Base

      attr_reader :meditation, :field_name, :current_state

      def initialize( meditation, field_name )
        @meditation    = meditation
        @field_name    = field_name
        @current_state = find_current_state()

        if current_state.nil?
          Zen.logger.info("Note: #{object} has an undefined current state.")
          Zen.logger.info("Note: Koan #{koan} has no states") if koan.states.empty?
        else
          persist!
        end
      end

      def find_current_state
        string = read_attribute()
        if string.blank?
          koan.initial_state
        else
          state_name = string.to_sym
          state      = koan.states[ state_name ]
          state || raise( Zen::InvalidStateName, string )
        end
      end

      def koan
        meditation.koan
      end

      def object
        meditation.disciple
      end

      def klass
        object.class
      end

      def method_name
        meditation.method_name
      end

      def current_state=( state )
        raise(ArgumentError, state.inspect) unless
          state.is_a?(Zen::State)
        @current_state = state
        persist!
      end

      def value()
        @current_state && @current_state.name.to_s
      end

      def persist!
        write_attribute( value() )
      end

      private

      def read_attribute
        raise "Abstract method! override me"
      end

      def write_attribute( string_value )
        raise "Abstract method! override me"
      end

    end
  end
end


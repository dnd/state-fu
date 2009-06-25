module StateFu

  class InvalidStateName < Exception
  end

  module Persistence
    class Base

      attr_reader :binding, :field_name, :current_state

      def self.prepare_class( klass )
        unless klass.instance_methods.include?( :method_missing_before_state_fu )
          alias_method :method_missing_before_state_fu, :method_missing
          klass.class_eval do
            def method_missing( method_name, *args, &block )
              state_fu!
              begin
                send( method_name, *args, &block )
              rescue NoMethodError => e
                method_missing_before_state_fu( method_name, *args, &block )
              end
            end
          end
        end
      end

      def self.prepare_field( klass, field_name )
        raise NotImplementedError # abstract method
      end

      def initialize( binding, field_name )
        @binding       = binding
        @field_name    = field_name
        @current_state = find_current_state()

        if current_state.nil?
          Logger.warn("undefined state for binding #{binding} on #{object} with field_name #{field_name.inspect}")
          Logger.warn("Machine for #{object} has no states: #{machine}") if machine.states.empty?
        else
          persist!
          Logger.debug("#{object} resumes #{binding.method_name} at #{current_state.name}")
        end
      end

      def find_current_state
        string = read_attribute()
        if string.blank?
          machine.initial_state
        else
          state_name = string.to_sym
          state      = machine.states[ state_name ] || raise( StateFu::InvalidStateName, string )
        end
      end

      def machine
        binding.machine
      end

      def object
        binding.object
      end

      def klass
        object.class
      end

#      def method_name
#        binding.method_name
#      end

      def current_state=( state )
        raise(ArgumentError, state.inspect) unless state.is_a?(StateFu::State)
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


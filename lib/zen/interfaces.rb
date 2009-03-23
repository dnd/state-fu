module Zen
  module Interfaces

    # Code shared between Zen::State & Zen::Event
    module StateAndEvent
      attr_reader :koan, :name, :options
      def initialize(koan, name, options={})
        @koan    = koan
        @name    = name.to_sym
        @options = options.symbolize_keys!
      end

      def apply!( options={}, &block )
        if block_given?
          case block.arity
          when 1     # lambda{ |state| ... }.arity
            yield self
          when -1, 0 # lambda{ }.arity ( -1 in ruby 1.8.x but 0 in 1.9.x )
            instance_eval &block
          end
        end
        @options.merge!( options.symbolize_keys! )
        self
      end
      alias_method :update!, :apply!

      # sneaky way to make some comparisons a bit cleaner
      def to_sym
        name
      end

    end

    # included in the respective classes
    State = StateAndEvent
    Event = StateAndEvent

  end
end

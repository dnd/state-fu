module Zen
  module Interfaces

    # Code shared between Zen::State & Zen::Event
    module StateAndEvent
      attr_reader :koan, :name, :options
      def initialize(koan, name, options={}, &block)
        @koan    = koan
        @name    = name.to_sym
        @options = options.symbolize_keys!
        if block_given?
          case block.arity
          when 1     # lambda{ |state| ... }.arity
            yield self
          when -1, 0 # lambda{ }.arity ( -1 in ruby 1.8.x but 0 in 1.9.x )
            instance_eval &block
          end
        end
      end

      def update!( options={}, &block )
        @options.merge!( options.symbolize_keys! )
        self.instance_eval &block if block_given?
        self
      end

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

module Zen
  module Interfaces
    module StateAndEvent
      # DRY up duplicated code
      attr_reader :koan, :name, :options

      # TODO - do something with options
      def initialize(koan, name, options={}, &block)
        @koan    = koan
        @name    = name.to_sym
        @options = options.symbolize_keys!
        if block_given?
          case block.arity
          when 1
            yield self
          when 0
            instance_eval &block
          end
        end
      end

      def update!( options={}, &block )
        @options.merge!( options.symbolize_keys! )
        self.instance_eval &block if block_given?
        self
      end
    end

    State = StateAndEvent
    Event = StateAndEvent
  end
end

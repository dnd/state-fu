module Zen
  module Interfaces

    # Code shared between Zen::State & Zen::Event
    module StateAndEvent
      attr_reader :koan, :name, :options, :hooks
      def initialize(koan, name, options={})
        @koan    = koan
        @name    = name.to_sym
        @options = options.symbolize_keys!
        @hooks   = Zen::Hooks.for( self )
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

      def define_hook *args, &block # type, names, options={}, &block
        options      = args.extract_options!.symbolize_keys!
        type         = args.shift
        method_names = args
        Logger.info "define_hook: not implemented"
      end

      def add_hook slot, name, value
        @hooks[slot.to_sym] << [name.to_sym, value]
      end

      def before *a, &b
        define_hook :before, *a, &b
      end

      def on_exit *a, &b
        define_hook :exit, *a, &b
      end

      def execute *a, &b
        define_hook :execute, *a, &b
      end

      def on_entry *a, &b
        define_hook :entry, *a, &b
      end

      def after *a, &b
        define_hook :after, *a, &b
      end

      def accepted *a, &b
        define_hook :accepted, *a, &b
      end


    end

    # included in the respective classes
    State = StateAndEvent
    Event = StateAndEvent

  end
end

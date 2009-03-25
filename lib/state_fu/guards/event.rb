module StateFu
  module Guards
    class Event

      attr_reader :transition

      def initialize( transition, name, options={}, &block )
        @transition = transition
        super( transition.machine, name, options, block )
      end

      def valid?
        call( transition )
      end

    end
  end
end

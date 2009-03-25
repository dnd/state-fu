module StateFu
  class Guard
    class State

      def initialize( koan, name, options={}, &block )
        super( koan, name, options, block )
      end

      # passed a collection of StateFu::States, return those which are
      # valid targets.
      def select( *states, object )
        states.flatten.select do |state|
          call( state )
        end
      end

    end
  end
end

module Zen
  module API

    module Stateful
      module ClassMethods
        # Well what have we here, a stickler for ironed shirts and
        # folded socks?  Don't worry, we've got you covered.
        #
        # Access the most pregnant-with-meaning-holy-texts of the
        # ancient masters with a modern, snappy name.
        def statefully( *a, &b )
          koan( *a, &b )
        end
      end

      module InstanceMethods
        public
        # As above.
        # ...
        #
        def stateful( *a )
          om *a
        end

        # instantiate all meditations (or those named)
        # it's useful to call this before_create w/
        # ActiveRecord classes.
        def initialize_state!( *a )
          meditate!( *a )
        end

      end
    end
  end
end

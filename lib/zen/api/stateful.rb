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
        # This is your new swiss army knife.
        # The object with all the references and conveniences you'll need.
        def stateful( *a )
          om *a
        end

        # initialize all meditations ... er .. statefuls? (or those named)
        # it's useful to call this w/ before_create when using
        # ActiveRecord classes.
        def initialize_state!( *a )
          meditate!( *a )
        end
      end

    end
  end
end

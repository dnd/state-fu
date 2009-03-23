module Zen
  module API
    module Default

      module ClassMethods

        # Given no arguments, return the default koan (:om) for the
        # class, if it exists (or nil).
        #
        # Given a symbol, return the koan by that name if it exists
        # (or nil).
        #
        # Given a block, create the koan (:om if no name is supplied)
        # if it does not yet exist, and define it with the contents of
        # the block.
        #
        # This can be done multiple times; changes are cumulative.
        #
        # Calling Klass.koan with or without a block will create one if
        # it does not exist, and bind it to your class.
        #
        # You can have as many as you like per class.
        #
        # Klass.koan            # the default koan named :om
        #                       # equivalent to Klass.koan(:om)
        # Klass.koan(:workflow) # another totally separate koan

        # koan( name=:om, options[:field_name], &block )
        def koan( *args, &block )
          options = args.extract_options!.symbolize_keys!
          name    = args[0] || Zen::DEFAULT_KOAN
          Zen::Koan.for_class( self, name, options, &block )
        end

        # return a hash of :name => Zen::Koan for your class.
        def koans()
          Zen::Space.class_koans[self]
        end

        # return the list of koans names for this class
        def koan_names()
          Zen::Space.class_koans[self].keys
        end

      end

      module InstanceMethods
        private
        def _om
          @_om ||= {}
        end

        # .om() is the instance method your objects use to meditate.
        #
        # A Zen::Meditation comes into being, linking your object and
        # a koan, when you first call om() for that koan.
        #
        # Like the class method .koan(), calling it without any arguments
        # is equivalent to passing :om.
        #
        # Essentially, this is the accessor method through which an instance
        # can see and change its state, interact with events, etc.
        #
        public
        def om( koan_name=Zen::DEFAULT_KOAN )
          name = koan_name.to_sym
          if koan = Zen::Space.class_koans[self.class][name]
            _om[name] ||= Zen::Meditation.new( koan, self, name )
          end
        end

        # Gain awareness of all meditations this object has
        # contemplated into being.
        # Returns a Hash of { :name => <Zen::Meditation>, ... }
        def meditations()
          _om
        end
        alias_method :oms, :meditations

        # Instant enlightenment. Instantiate all meditations.
        # It's useful to call this before_create w/
        # ActiveRecord classes, as this will cause the database field
        # to be populated with the default state name.
        def meditate!( *names )
          if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
            names = self.class.koan_names()
          end
          names.map { |n| om( n ) }
        end

      end
    end
  end
end

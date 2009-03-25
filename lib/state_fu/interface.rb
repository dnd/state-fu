module StateFu
  module Interface
    # Provides access to StateFu to your classes.  Plenty of aliases are
    # provided so you can use whatever makes sense to you.
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
        name    = args[0] || StateFu::DEFAULT_KOAN
        StateFu::Koan.for_class( self, name, options, &block )
      end
      alias_method :statefully, :koan
      alias_method :machine,    :koan
      alias_method :workflow,   :koan
      alias_method :zen_koan,   :koan

      # return a hash of :name => StateFu::Koan for your class.
      def koans()
        StateFu::Space.class_koans[self]
      end
      alias_method :machines,    :koans
      alias_method :workflows,   :koans
      alias_method :zen_koans,   :koans

      # return the list of koans names for this class
      def koan_names()
        StateFu::Space.class_koans[self].keys
      end
      alias_method :machine_names,    :koan_names
      alias_method :workflow_names,   :koan_names
      alias_method :zen_koan_names,   :koan_names
    end

    # Give the gift of self-awareness to your objects. These methods
    # grant access to StateFu::Meditation objects, which are bundles of
    # context linking a StateFu::Koan to an object / instance.
    # Again, plenty of aliases are provided so you can use whatever
    # makes sense to you.
    module InstanceMethods
      private
      def _om
        @_om ||= {}
      end

      # .om() is the instance method your objects use to meditate.
      #
      # A StateFu::Meditation comes into being, linking your object and
      # a koan, when you first call om() for that koan.
      #
      # Like the class method .koan(), calling it without any arguments
      # is equivalent to passing :om.
      #
      # Essentially, this is the accessor method through which an instance
      # can see and change its state, interact with events, etc.
      #
      public
      def om( koan_name=StateFu::DEFAULT_KOAN )
        name = koan_name.to_sym
        if koan = StateFu::Space.class_koans[self.class][name]
          _om[name] ||= StateFu::Meditation.new( koan, self, name )
        end
      end
      alias_method :stateful,   :om
      alias_method :zen,        :om
      alias_method :koan,       :om
      alias_method :zen_koan,   :om
      alias_method :meditation, :om
      alias_method :machine,    :om
      alias_method :present,    :om

      # Gain awareness of all meditations (state contexts) this object
      # has contemplated into being.
      # Returns a Hash of { :name => <StateFu::Meditation>, ... }
      def meditations()
        _om
      end
      alias_method :oms,       :meditations
      alias_method :koans,     :meditations
      alias_method :zen_koans, :meditations
      alias_method :machines,  :meditations

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
      alias_method :initialize_state!, :meditate!
      alias_method :zen!,              :meditate!
      alias_method :koan_init!,        :meditate!
      alias_method :awaken!,           :meditate!

    end
  end
end

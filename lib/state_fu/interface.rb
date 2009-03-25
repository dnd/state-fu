module StateFu
  module Interface
    # Provides access to StateFu to your classes.  Plenty of aliases are
    # provided so you can use whatever makes sense to you.
    module ClassMethods

      # Given no arguments, return the default machine (:om) for the
      # class, if it exists (or nil).
      #
      # Given a symbol, return the machine by that name if it exists
      # (or nil).
      #
      # Given a block, create the machine (:om if no name is supplied)
      # if it does not yet exist, and define it with the contents of
      # the block.
      #
      # This can be done multiple times; changes are cumulative.
      #
      # Calling Klass.machine with or without a block will create one if
      # it does not exist, and bind it to your class.
      #
      # You can have as many as you like per class.
      #
      # Klass.machine            # the default machine named :om
      #                       # equivalent to Klass.machine(:om)
      # Klass.machine(:workflow) # another totally separate machine

      # machine( name=:om, options[:field_name], &block )
      def machine( *args, &block )
        options = args.extract_options!.symbolize_keys!
        name    = args[0] || StateFu::DEFAULT_KOAN
        StateFu::Machine.for_class( self, name, options, &block )
      end
      alias_method :statefully,    :machine
      alias_method :machine,       :machine
      alias_method :workflow,      :machine
      alias_method :state_machine, :machine

      # return a hash of :name => StateFu::Machine for your class.
      def machines( *args, &block )
        if args.empty? && !block_given?
          StateFu::FuSpace.class_machines[self]
        else
          machine( *args, &block)
        end
      end
      alias_method :machines,     :machines
      alias_method :workflows,    :machines
      alias_method :zen_machines, :machines

      # return the list of machines names for this class
      def machine_names()
        StateFu::FuSpace.class_machines[self].keys
      end
      alias_method :machine_names,    :machine_names
      alias_method :workflow_names,   :machine_names
      alias_method :zen_machine_names,   :machine_names
    end

    # Give the gift of self-awareness to your objects. These methods
    # grant access to StateFu::Binding objects, which are bundles of
    # context linking a StateFu::Machine to an object / instance.
    # Again, plenty of aliases are provided so you can use whatever
    # makes sense to you.
    module InstanceMethods
      private
      def _om
        @_om ||= {}
      end

      # .om() is the instance method your objects use to meditate.
      #
      # A StateFu::Binding comes into being, linking your object and
      # a machine, when you first call om() for that machine.
      #
      # Like the class method .machine(), calling it without any arguments
      # is equivalent to passing :om.
      #
      # Essentially, this is the accessor method through which an instance
      # can see and change its state, interact with events, etc.
      #
      public
      def om( machine_name=StateFu::DEFAULT_KOAN )
        name = machine_name.to_sym
        if machine = StateFu::FuSpace.class_machines[self.class][name]
          _om[name] ||= StateFu::Binding.new( machine, self, name )
        end
      end
      alias_method :stateful,   :om
      alias_method :zen,        :om
      alias_method :machine,       :om
      alias_method :zen_machine,   :om
      alias_method :binding, :om
      alias_method :machine,    :om
      alias_method :present,    :om

      # Gain awareness of all bindings (state contexts) this object
      # has contemplated into being.
      # Returns a Hash of { :name => <StateFu::Binding>, ... }
      def bindings()
        _om
      end
      alias_method :oms,       :bindings
      alias_method :machines,     :bindings
      alias_method :zen_machines, :bindings
      alias_method :machines,  :bindings

      # Instant enlightenment. Instantiate all bindings.
      # It's useful to call this before_create w/
      # ActiveRecord classes, as this will cause the database field
      # to be populated with the default state name.
      def meditate!( *names )
        if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
          names = self.class.machine_names()
        end
        names.map { |n| om( n ) }
      end
      alias_method :initialize_state!, :meditate!
      alias_method :zen!,              :meditate!
      alias_method :machine_init!,        :meditate!
      alias_method :awaken!,           :meditate!

    end
  end
end

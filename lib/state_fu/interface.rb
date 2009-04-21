module StateFu
  module Interface
    # Provides access to StateFu to your classes.  Plenty of aliases are
    # provided so you can use whatever makes sense to you.
    module ClassMethods

      # TODO:
      # take option :alias => false (disable aliases) or :alias
      # => :foo (use foo as class & instance accessor)

      #
      # Given no arguments, return the default machine (:state_fu) for the
      # class, creating it if it did not exist.
      #
      # Given a symbol, return the machine by that name, creating it
      # if it didn't exist.
      #
      # Given a block, also define it with the contents of the block.
      #
      # This can be done multiple times; changes are cumulative.
      #
      # You can have as many machines as you like per class.
      #
      # Klass.machine            # the default machine named :om
      #                          # equivalent to Klass.machine(:om)
      # Klass.machine(:workflow) # another totally separate machine
      #
      # machine( name=:state_fu, options[:field_name], &block )

      def machine( *args, &block )
        options = args.extract_options!.symbolize_keys!
        name    = args[0] || StateFu::DEFAULT_MACHINE
        StateFu::Machine.for_class( self, name, options, &block )
      end
      alias_method :stfu,          :machine
      alias_method :state_fu,      :machine
      alias_method :workflow,      :machine
      alias_method :statefully,    :machine
      alias_method :state_machine, :machine
      alias_method :stateful,      :machine
      alias_method :workflow,      :machine
      alias_method :engine,        :machine

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
      alias_method :engines,      :machines

      # return the list of machines names for this class
      def machine_names()
        StateFu::FuSpace.class_machines[self].keys
      end
      alias_method :machine_names,       :machine_names
      alias_method :workflow_names,      :machine_names
      alias_method :engine_names,        :machine_names
    end

    # Give the gift of state to your objects. These methods
    # grant access to StateFu::Binding objects, which are bundles of
    # context linking a StateFu::Machine to an object / instance.
    # Again, plenty of aliases are provided so you can use whatever
    # makes sense to you.
    module InstanceMethods
      private
      def _state_fu
        @_state_fu ||= {}
      end

      # A StateFu::Binding comes into being, linking your object and a
      # machine, when you first call yourobject.binding() for that
      # machine.
      #
      # Like the class method .machine(), calling it without any arguments
      # is equivalent to passing :om.
      #
      # Essentially, this is the accessor method through which an instance
      # can see and change its state, interact with events, etc.
      #
      public
      def _binding( name=StateFu::DEFAULT_MACHINE )
        name = name.to_sym
        if mach = StateFu::FuSpace.class_machines[self.class][name]
          _state_fu[name] ||= StateFu::Binding.new( mach, self, name )
        end
      end

      alias_method :fu,          :_binding
      alias_method :stfu,        :_binding
      alias_method :state_fu,    :_binding
      alias_method :stateful,    :_binding
      alias_method :workflow,    :_binding
      alias_method :engine,      :_binding
      alias_method :context,     :_binding


      # Gain awareness of all bindings (state contexts) this object
      # has contemplated into being.
      # Returns a Hash of { :name => <StateFu::Binding>, ... }
      def _bindings()
        _state_fu
      end

      alias_method :fus,          :_bindings
      alias_method :stfus,        :_bindings
      alias_method :state_fus,    :_bindings
      alias_method :state_foos,   :_bindings
      alias_method :workflows,    :_bindings
      alias_method :engines,      :_bindings
      alias_method :bindings,     :_bindings
      alias_method :machines,     :_bindings # not strictly accurate, but makes sense sometimes
      alias_method :contexts,     :_bindings

      # Instantiate bindings for all machines defined for this class.
      # It's useful to call this before_create w/
      # ActiveRecord classes, as this will cause the database field
      # to be populated with the default state name.
      def state_fu!( *names )
        if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
          names = self.class.machine_names()
        end
        names.map { |n| _binding( n ) }
      end
      alias_method :fu!,               :state_fu!
      alias_method :stfu!,             :state_fu!
      alias_method :state_fu!,         :state_fu!
      alias_method :init_machines!,    :state_fu!
      alias_method :initialize_state!, :state_fu!
      alias_method :build_workflow!,   :state_fu!
    end
  end
end

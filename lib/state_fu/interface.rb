module StateFu
  module Interface
    module SoftAlias
      def soft_alias(x)
        aliases  = [ x.to_a[0] ].flatten
        original = aliases.shift
        existing_method_names = (self.instance_methods | self.protected_instance_methods | self.private_instance_methods).map(&:to_sym)
        taken, ok = aliases.partition { |a| existing_method_names.include?(a.to_sym) }
        StateFu::Logger.info("#{self.to_s} alias for ## #{original} TAKEN: #{taken.inspect}")  unless taken.empty?
        ok.each { |a| alias_method a, original}
      end
    end

    module Aliases

      def self.extended(base)
        base.extend SoftAlias
        base.class_eval do
          # instance method aliases
          soft_alias :state_fu          => [:stfu, :fu, :stateful, :workflow, :engine, :machine, :context]
          soft_alias :state_fu_bindings => [:state_fus, :fus, :stfus, :state_foos, :workflows, :engines, :bindings, :machines, :contexts]
          soft_alias :state_fu!         => [:stfu!, :init_machines!, :initialize_state!, :build_workflow! ]
          class << self
            extend SoftAlias
            # class method aliases
            soft_alias :machine       => [:stfu, :state_fu, :workflow, :stateful, :statefully, :state_machine, :engine ]
            soft_alias :machines      => [:stfus, :state_fus, :workflows, :engines]
            soft_alias :machine_names => [:stfu_names, :state_fu_names, :workflow_names, :engine_names]
          end
        end
      end
    end

    # Provides access to StateFu to your classes.  Plenty of aliases are
    # provided so you can use whatever makes sense to you.
    module ClassMethods

      # TODO:
      # take option :alias => false (disable aliases) or :alias
      # => :foo (add :foo as class & instance accessor methods)

      # Given no arguments, return the default machine (:state_fu) for the
      # class, creating it if it did not exist.
      #
      # Given a symbol, return the machine by that name, creating it
      # if it didn't exist, and definining it if a block is passed.
      #
      # Given a block, apply it to a StateFu::Lathe to define a
      # machine, and return it.
      #
      # This can be done multiple times; changes are cumulative.
      #
      # You can have as many machines as you like per class.
      #
      # Klass.machine            # the default machine named :om
      #                          # equivalent to Klass.machine(:om)
      # Klass.machine(:workflow) # another totally separate machine
      #
      # recognised options are:
      #  :field_name - specify the field to use for persistence.
      #  defaults to {machine_name}_field.
      #

      def machine( *args, &block )
        options = args.extract_options!.symbolize_keys!
        name    = args[0] || StateFu::DEFAULT_MACHINE
        StateFu::Machine.for_class( self, name, options, &block )
      end

      # return a hash of :name => StateFu::Machine for your class.
      def machines( *args, &block )
        if args.empty? && !block_given?
          StateFu::FuSpace.machines[self]
        else
          machine( *args, &block)
        end
      end

      # return the list of machines names for this class
      def machine_names
        StateFu::FuSpace.machines[self].keys
      end
    end

    # These methods grant access to StateFu::Binding objects, which
    # are bundles of context encapsulating a StateFu::Machine, an instance
    # of a class, and its current state in the machine.

    # Again, plenty of aliases are provided so you can use whatever
    # makes sense to you.
    module InstanceMethods
      private
      def _state_fu
        @_state_fu ||= {}
      end

      # A StateFu::Binding comes into being when it is first referenced.
      #
      # This is the accessor method through which an object instance (or developer)
      # can access a StateFu::Machine, the object's current state, the
      # methods which trigger event transitions, etc.
      public
      def _binding( name=StateFu::DEFAULT_MACHINE )
        name = name.to_sym
        if mach = StateFu::FuSpace.machines[self.class][name]
          _state_fu[name] ||= StateFu::Binding.new( mach, self, name )
        end
      end
      alias_method :state_fu,    :_binding

      # Gain awareness of all bindings (state contexts) this object
      # has contemplated into being.
      # Returns a Hash of { :name => <StateFu::Binding>, ... }
      def _bindings()
        _state_fu
      end
      alias_method :state_fu_bindings, :_bindings

      # Instantiate bindings for all machines defined for this class.
      # It's useful to call this before_create w/
      # ActiveRecord classes, as this will cause the database field
      # to be populated with the default state name.
      def state_fu!( *names )
        if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
          names = self.class.machine_names()
        end
        @state_fu_initialized = true
        names.map { |n| _binding( n ) }
      end

    end # ClassMethods
  end # Interface
end # StateFu

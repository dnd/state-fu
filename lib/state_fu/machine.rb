module StateFu
  class Machine
    include StateFu::Applicable

    #
    # Class methods
    # 
    
    # meta-constructor; expects to be called via Klass.machine()
    def self.for_class(klass, name, options={}, &block)
      options.symbolize_keys!
      name = name.to_sym
      
      unless machine = klass.state_fu_machines[ name ]
        machine = new( name, options, &block )
        machine.bind!( klass, name, options[:field_name] )
      end
      if block_given?
        machine.apply!( &block )
      end
      machine
    end

    # make it so that a class which has included StateFu has a binding to
    # this machine
    def self.bind!( machine, owner, name, field_name)
      name                             = name.to_sym
      owner.state_fu_machines[name]    = machine
      owner.state_fu_field_names[name] = field_name

      # method_missing to catch NoMethodError for event methods, etc
      StateFu::MethodFactory.prepare_class( owner )

      # define an accessor method with the given name
      if owner.class == Class 
        unless owner.respond_to?(name)       
          owner.class_eval do
            define_method name do
              state_fu( name )
            end
          end
        end   
        # prepare the persistence field
        StateFu::Persistence.prepare_field( owner, field_name )
      else 
        # singleton machine ? 
        raise NotImplementedError, "StateFu doesn't support singleton machines yet"
      end 
    end

    ##
    ## Instance Methods
    ##

    attr_reader :states, :events, :options, :helpers, :named_procs, :requirement_messages, :tools

    def initialize( name, options={}, &block )
      # TODO - name isn't actually used anywhere yet - remove from constructor
      @states  = [].extend( StateArray  )
      @events  = [].extend( EventArray  )
      @helpers = [].extend( HelperArray )
      @tools   = [].extend( ToolArray   )
      @named_procs          = {}
      @requirement_messages = {}
      @options              = options
    end

    # merge the commands in &block with the existing machine; returns
    # a lathe for the machine.
    def apply!( &block )
      StateFu::Lathe.new( self, &block )
    end
    alias_method :lathe, :apply!

    def helper_modules
      helpers.modules
    end

    def inject_helpers_into( obj )
      helpers.inject_into( obj )
    end

    def inject_tools_into( obj )
      tools.inject_into( obj )
    end

    # the modules listed here will be mixed into Binding and
    # Transition objects for this machine. use this to define methods,
    # references or data useful to you during transitions, event
    # hooks, or in general use of StateFu.
    #
    # They can be supplied as a string/symbol (as per rails controller
    # helpers), or a Module.
    #
    # To do this globally, just duck-punch StateFu::Machine /
    # StateFu::Binding.
    def helper *modules_to_add
      modules_to_add.each { |mod| helpers << mod }
    end

    # same as helper, but for extending Lathes rather than the Bindings / Transitions.
    # use this to extend the Lathe DSL to suit your problem domain.
    def tool *modules_to_add
      modules_to_add.each { |mod| tools << mod }
    end

    # make it so a class which has included StateFu has a binding to
    # this machine
    def bind!( owner, name= DEFAULT, field_name = nil )
      field_name ||= Persistence.default_field_name( name )
      self.class.bind!(self, owner, name, field_name)
    end

    def empty?
      states.empty?
    end

    def initial_state=( s )
      case s
      when Symbol, String, StateFu::State
        unless init_state = states[ s.to_sym ]
          init_state = StateFu::State.new( self, s.to_sym )
          states << init_state
        end
        @initial_state = init_state
      else
        raise( ArgumentError, s.inspect )
      end
    end

    def initial_state()
      @initial_state ||= states.first
    end

    def state_names
      states.map(&:name)
    end

    def event_names
      events.map(&:name)
    end

    # given a messy bunch of symbols, find or create a list of
    # matching States.
    def find_or_create_states_by_name( *args )
      args = args.compact.flatten
      raise ArgumentError.new( args.inspect ) unless args.all? { |a| [Symbol, StateFu::State].include? a.class }
      args.map do |s|
        unless state = states[s.to_sym]
          # TODO clean this line up
          state = s.is_a?( StateFu::State ) ? s : StateFu::State.new( self, s )
          self.states << state
        end
        state
      end
    end

    # Marshal, the poor man's X-Ray photocopier.
    # TODO: a version which will not break its teeth on procs
    def deep_clone
      Marshal::load(Marshal.dump(self))
    end
    alias_method :deep_copy, :deep_clone

    def inspect
      "#<#{self.class} ##{__id__} states=#{state_names.inspect} events=#{event_names.inspect} options=#{options.inspect}>"
    end

    def graphviz
      @graphviz ||= Plotter.new(self).output
    end

  end
end

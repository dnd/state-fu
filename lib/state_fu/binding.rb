module StateFu
  class Binding

    attr_reader :object, :machine, :method_name, :persister, :transitions

    def initialize( machine, object, method_name )
      @machine       = machine
      @object        = object
      @method_name   = method_name
      @transitions   = []
      field_name     = StateFu::FuSpace.field_names[object.class][@method_name]
      raise( ArgumentError, "No field_name" ) unless field_name
      @persister     = StateFu::Persistence.for( self, field_name )
      Logger.info( "Persister added: #@persister ")
    end
    alias_method :o,         :object
    alias_method :obj,       :object
    alias_method :model,     :object
    alias_method :instance,  :object

    alias_method :machine,       :machine
    alias_method :workflow,      :machine
    alias_method :state_machine, :machine

    def field_name
      persister.field_name
    end

    def current_state
      persister.current_state
    end
    alias_method :at,    :current_state
    alias_method :state, :current_state

    def transition( event, target=nil, options={}, &block )
      StateFu::Transition.new( self, event, target, options, &block )
    end

    # fire event
    def fire!( event, target=nil, options={}, &block)
      t = transition( event, target, options, &block )
      t.fire!
      t
    end
    alias_method :call!,       :fire!
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

    # fire event to move to the next state, if there is only one possible state.
    # otherwise raise an error ( NoNextStateError)
    def next!( *args, &block)
      raise "!"
    end
    alias_method :next_state!, :next!

    def cycle!( *args, &block )
      raise "!"
    end

    alias_method :call!,       :fire!
    alias_method :trigger!,    :fire!
    alias_method :transition!, :fire!

  end
end

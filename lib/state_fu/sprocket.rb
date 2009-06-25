module StateFu
  class Sprocket # Abstract Superclass of State & Event
    include StateFu::Helper # define apply!

    attr_reader :machine, :name, :options, :hooks

    def initialize(machine, name, options={})
      @machine = machine
      @name    = name.to_sym
      @options = options.symbolize_keys!
      @hooks   = StateFu::Hooks.for( self )
    end

    # sneaky way to make some comparisons / duck typing a bit cleaner
    alias_method :to_sym,  :name

    def add_hook slot, name, value
      @hooks[slot.to_sym] << [name.to_sym, value]
    end

    def lathe(options={}, &block)
      StateFu::Lathe.new( machine, self, options, &block )
    end

    def deep_copy
      raise NotImeplementedError # abstract
    end

    def to_s
      "#<#{self.class}::#{self.object_id} @name=#{name.inspect}>"
    end

  end
end


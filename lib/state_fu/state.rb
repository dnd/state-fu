module StateFu
  class State < StateFu::Sprocket

    attr_reader :entry_requirements, :exit_requirements

    def initialize(machine, name, options={})
      @entry_requirements = [].extend ArrayWithSymbolAccessor
      @exit_requirements  = [].extend ArrayWithSymbolAccessor
      super( machine, name, options )
    end

    def events
      machine.events.from(self)
    end

    #
    # Proxy methods to StateFu::Lathe
    #
    # TODO - build something meta to build these proxy events
    def event( name, options={}, &block )
      if block_given?
        lathe.event( name, options, &block )
      else
        lathe.event( name, options )
      end
    end

    def enterable_by?( binding, *args )
      entry_requirements.reject do |r|
        res = binding.evaluate_requirement_with_args( r, *args )
      end.empty?
    end

    def exitable_by?( binding, *args )
      exit_requirements.reject do |r|
        binding.evaluate_requirement_with_args( r, *args )
      end.empty?
    end

    # allows @obj.state_fu.state === :new
    def === other
      self.to_sym === other.to_sym
    end

    def inspect
      s = self.to_s
      s = s[0,s.length-1]
      display_hooks = hooks.dup
      display_hooks.each do |k,v|
        display_hooks.delete(k) if v.empty?
      end
      unless display_hooks.empty?
        s << "hooks=#{display_hooks.inspect} "
      end
      unless entry_requirements.empty?
        s << "entry_requirements=#{entry_requirements.inspect} "
      end
      unless exit_requirements.empty?
        s << "exit_requirements=#{exit_requirements.inspect}"
      end
      s << ">"
      s
    end

    def to_s
      "#<#{self.class}::#{self.object_id} @name=#{name.inspect}>"
    end

  end
end

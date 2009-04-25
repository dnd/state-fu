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

    def enterable_by?( binding )
      entry_requirements.reject do |r|
        res = binding.evaluate_requirement( r )
      end.empty?
    end

    def exitable_by?( binding )
      exit_requirements.reject do |r|
        binding.evaluate_requirement( r )
      end.empty?
    end

    # allows @obj.state_fu.state === :new
    def === other
      self.to_sym === other.to_sym
    end
  end
end

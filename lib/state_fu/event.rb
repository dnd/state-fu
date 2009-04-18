module StateFu
  class Event < StateFu::Sprocket

    attr_reader :origins, :targets, :requirements

    #
    # TODO - event guards
    #

    def initialize(machine, name, options={})
      @requirements = [].extend ArrayWithSymbolAccessor
      super( machine, name, options )
    end

    def origin_names
      origins ? origins.map(&:to_sym) : nil
    end

    def target_names
      targets ? targets.map(&:to_sym) : nil
    end

    def to?( state )
      target_names.include?( state.to_sym )
    end

    def from?( state )
      origin_names.include?( state.to_sym )
    end

    def origins=( *args )
      @origins = machine.find_or_create_states_by_name( *args.flatten )
    end

    def targets=( *args )
      @targets = machine.find_or_create_states_by_name( *args.flatten )
    end

    # complete?(:origins) # do we have an origins?
    # complete?          # do we have an origins and targets?
    def complete?( field = nil )
      ( field && [field] ||  [:origins, :targets] ).
        map{ |s| send(s) }.
        all?{ |f| !(f.nil? || f.empty?) }
    end

    def origin
      origins && origins.length == 1 && origins[0] || nil
    end

    def target
      targets && targets.length == 1 && targets[0] || nil
    end

    def simple?
      !! ( origin && target )
    end

    def from *args
      options = args.extract_options!.symbolize_keys!
      args.flatten!
      to = options.delete(:to)
      if args.empty? && !to
        if options.length == 1
          self.origins= options.keys[0]
          self.targets= options.values[0]
        else
          raise options.inspect
        end
      else
        self.origins= *args
        self.targets= to unless to.nil?
      end
    end

    def to *args
      options = args.extract_options!.symbolize_keys!
      args.flatten!
      raise options.inspect unless options.empty?
      self.targets= *args
    end

    def fireable_by?( binding )
      requirements.reject do |r|
        binding.evaluate_requirement( r )
      end.empty?
    end

  end
end

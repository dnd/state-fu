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

    def origins=( arg )
      @origins = get_states_list_by_name( arg )
    end

    def targets=( arg )
      @targets = get_states_list_by_name( arg )
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

    #
    # Proxy methods to StateFu::Lathe
    #
    def from *a, &b
      lathe.from( *a, &b )
    end

    def to *a, &b
      lathe.to( *a, &b )
    end

    def fireable_by?( binding )
      requirements.reject do |r|
        binding.evaluate_requirement( r )
      end.empty?
    end

    private
    def get_states_list_by_name( list )
      machine.find_or_create_states_by_name( [list].flatten.map(&:to_sym) )
    end

  end
end

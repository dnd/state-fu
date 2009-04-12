module StateFu
  class Event < StateFu::Sprocket

    attr_reader :origin, :target

    #
    # TODO - event guards
    #

    def origin_names
      origin ? origin.map(&:to_sym) : nil
    end

    def target_names
      target ? target.map(&:to_sym) : nil
    end

    def to?( state )
      target_names.include?( state.to_sym )
    end

    def from?( state )
      origin_names.include?( state.to_sym )
    end

    def origin=( arg )
      @origin = get_states_list_by_name( arg )
    end

    def target=( arg )
      @target = get_states_list_by_name( arg )
    end

    # complete?(:origin) # do we have an origin?
    # complete?          # do we have an origin and target?
    def complete?( field = nil )
      ( field && [field] ||  [:origin, :target] ).
        map{ |s| send(s) }.
        all?{ |f| !(f.nil? || f.empty?) }
    end

    def single_target?
      target && target.is_a?( Array ) && target.length == 1
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

    private
    def get_states_list_by_name( list )
      machine.find_or_create_states_by_name( [list].flatten.map(&:to_sym) )
    end

  end
end

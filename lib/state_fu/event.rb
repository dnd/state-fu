module StateFu
  class Event < StateFu::Phrase

    attr_reader :origin, :target

    #
    # TODO - event guards
    #

    def origin_names
      # @origin_names ||=
      origin.map(&:to_sym) rescue nil
    end

    def target_names
      # @target_names ||=
      target.map(&:to_sym) rescue nil
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

    #
    # Proxy methods to StateFu::Reader
    #
    def from *a, &b
      reader.from( *a, &b )
    end

    def to *a, &b
      reader.to( *a, &b )
    end

    private
    def get_states_list_by_name( list )
      koan.find_or_create_states_by_name( [list].flatten.map(&:to_sym) )
    end

  end
end

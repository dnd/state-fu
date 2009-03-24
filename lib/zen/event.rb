module Zen
  class Event < Zen::Phrase

    attr_reader :origin, :target


    def needs *a, &b
    end
    #
    # TODO - event guards
    #

    def origin_names
      @origin_names ||= origin.map(&:to_sym) rescue nil
    end

    def target_names
      @target_names ||= target.map(&:to_sym) rescue nil
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

    # TODO ? move this stuff into Reader somehow?

    # TODO - add support for :all, :except, :only
    #
    # Sets @origin and optionally @target.
    # both can be supplied as a symbol, array of symbols.
    # any states referenced here will be created if they do not exist.
    def from *args, &block
      options           = args.extract_options!.symbolize_keys!
      self.origin       = args
      to                = options.delete(:to)
      to && self.target = to
      # @options.merge!( options )
      if block_given?
        apply!( options, &block )
      else
        apply!( options )
      end
    end

    # TODO - add support for :all, :except, :only
    #
    # Sets @target
    # can be supplied as a symbol, or array of symbols.
    # any states referenced here will be created if they do not exist.
    def to *args
      options       = args.extract_options!.symbolize_keys!
      self.target   = args
      # @options.merge!( options )
      if block_given?
        apply!( options, &block )
      else
        apply!( options )
      end
    end

    private
    def get_states_list_by_name( list )
      koan.find_or_create_states_by_name( [list].flatten.map(&:to_sym) )
    end

  end
end

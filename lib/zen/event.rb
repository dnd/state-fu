module Zen
  class Event
    attr_reader :origin, :target

    include Zen::Interfaces::Event

    def origin_names
      return nil unless static?(:origin)
      @origin_names ||= origin.map(&:to_sym)
    end

    def target_names
      return nil unless static?(:target)
      @target_names ||= target.map(&:to_sym)
    end

    def to?( state )
      target_names.include?( state.to_sym )
    end

    def from?( state )
      origin_names.include?( state.to_sym )
    end

    # TODO - add support for :all, :except, :only

    # set @origin and optionally @target
    # both can be supplied as a symbol, array of symbols or a proc
    # if a proc, ...
    # any states referenced here will be created if they do not exist.
    def from *args
      options           = args.extract_options!.symbolize_keys!
      self.origin       = args
      to                = options.delete(:to)
      to && self.target = to
      @options.merge!( options )
    end

    # set @target
    # can be supplied as a symbol, array of symbols or a proc
    # if a proc, ...
    # any states referenced here will be created if they do not exist.
    def to *args
      options       = args.extract_options!.symbolize_keys!
      self.target   = args
      @options.merge!( options )
    end

    def origin=( arg )
      _set_state_list( :origin, arg )
    end

    def target=( arg )
      _set_state_list( :target, arg )
    end

    # do we have an origin and target?
    def complete?
      [origin, target].flatten.compact.length == 2
    end

    def static?( *arg )
      arg = ( arg.empty? ? [:origin, :target] : arg ).map{ |a| send(a) }
      return nil if arg.any?(&:nil?)
      arg.all? do |a|
        a.is_a?(Array)
      end
    end

    # simple?( :origin ) # is the origin a single state?
    # simple?()          # is either the origin or target a single state?
    def simple?( *arg )
      arg = ( arg.empty? ? [:origin, :target] : arg ).map{ |a| send(a) }
      return nil if arg.any?(&:nil?)
      arg.all? do |a|
        a.is_a?(Array) && a.length == 1 && a.first.is_a?( Zen::State )
      end
    end

    # simple?( :origin ) # is the origin evaluated at runtime?
    # simple?()          # is either the origin or target evaluated at runtime?
    def dynamic?( *arg )
      arg = ( arg.empty? ? [:origin, :target] : arg ).map{ |a| send(a) }
      return nil if arg.any?(&:nil?)
      arg.any? {|a| a.is_a?(Proc) }
    end

    private

    # Fugly, it's true. Luckily you really shouldn't have to touch it.
    # Sanitizes and sets @origin or @target to either a Proc, or array
    # of Zen::States (creating any named but not yet in existence)
    def _set_state_list( attr, arg )
      raise( ArgumentError, attr) unless [:origin, :target].include?(attr)
      return false if arg.nil?
      arg = case arg
            when Array
              if arg.map(&:class) == [Proc]
                arg.first
              else
                arg.flatten.map(&:to_sym)
              end
            when Symbol, String
              [arg.to_sym]
            when Proc
              arg
            else
              raise(ArgumentError, "#{arg} should be a symbol, [symbols], or a Proc")
            end
      value = arg.is_a?(Proc) ? arg : koan.find_or_create_states_by_name( arg )
      instance_variable_set( "@#{attr.to_s}", value )
    end
  end

end

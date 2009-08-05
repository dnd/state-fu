module StateFu
  class TransitionQuery #< Array
    attr_accessor :binding, :options, :result, :args, :block

    def initialize(binding, options={})
      defaults = { :valid => true, :cyclic => nil }
      @options = defaults.merge(options).symbolize_keys
      @binding = binding
    end

    include Enumerable
    
    def each *a, &b
      result.each *a, &b
    end
    
    def length
      result.length
    end
    
    # def method_missing(method_name, *args, &block)
    #   if result.respond_to?(method_name)
    #     result.send method_name, *args, &block
    #   else
    #     super method_name, *args, &block
    #   end
    # end
    
    #
    #
    #
    def find( event_or_array )
      event, target = parse_destination(event_or_array)
      #if target.nil? 
      #  possible_targets = all_destinations.select {|evt, tgt| evt == event }.map(&:last)
      #  if possible_targets.length == 1
      #    target = possible_targets.first
      #  else
      #    raise TransitionNotFound.new(binding, {:event => event, :target => target})
      #  end
      #end
      binding.new_transition(event, target)
    end
    
    def cyclic
      @options.merge! :cyclic => true
      self
    end

    def not_cyclic
      @options.merge! :cyclic => false
      self
    end

    def valid
      @options.merge! :valid => true
      self
    end

    def not_valid
      @options.merge! :valid => false
      self
    end
    alias_method :invalid, :not_valid

    def to state
      @options.merge! :target => state
      self
    end

    def for event
      @options.merge! :event => event
      self
    end

    def simple
      @options.merge! :simple => true
      self
    end
    
    def singular
      result.first if result.length == 1
    end

    def next
      @options[:cyclic] ||= false
      singular
      # t = result.length == 1 && result.first || nil
      # t && t.apply!
      # t
    end

    def apply! # (&block
      result.each { |t| t.apply &block if block }
    end

    def with(*args, &block)
      @args = *args
      self
    end
    
    def all_destinations
      binding.events.inject([]){ |arr, evt| arr += evt.targets.map{|tgt| [evt,tgt] }; arr}.uniq
    end
    
    def all_destination_names
      all_destinations.map {|tuple| tuple.map(&:to_sym) }
    end

    private

    #
    # Result class
    #
    
    module Result
      def states
        map(&:target).uniq.extend StateArray
      end
      alias_method :targets, :states
      alias_method :next_states, :states

      def events
        map(&:event).uniq.extend EventArray
      end
    end # Result

    def result
      @result = binding.events.select do |e| 
        case options[:cyclic]
        when true
          e.cycle?
        when false
          !e.cycle?
        else
          true
        end
      end.map do |event|
        next if options[:event] and event != options[:event]
        returning [] do |ts|

          # hmm ... "sequences" ... TODO delete ?
          if options[:sequences]
            if target = event.target_for_origin(current_state)
              ts << binding.transition([event,target], *args) unless options[:cyclic]
            end
          end

          if event.targets
            next unless event.target if options[:simple]
            event.targets.flatten.each do |target|
              next if options[:target] and target != options[:target]
              t = binding.new_transition( event, target, *args)
              #  raise "#{event.name.to_s} #{target.name.to_s}" unless t.is_a?(Transition)
              ts << t if (t.valid? or !options[:valid])
            end
          end

        end
      end.flatten.extend(Result)
    end # result 

    # sanitizes / extracts destination for find.
    #
    # takes a single, simple (one target only) event,
    # or an array of [event, target],
    # or one of the above with symbols in place of the objects themselves.    
    def parse_destination(event_or_array)
      case event_or_array
      when Event, Symbol
        event  = event_or_array
        target = nil
      when Array
        event, target = *event_or_array
      end
      raise ArgumentError.new( [event,target].inspect ) unless
        [Event, Symbol].include?(event.class) &&
        [State, Symbol, NilClass].include?(target.class)
      [event, target]
    end # parse_destination

  end
end

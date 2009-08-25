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
        
    #
    #
    #
    
    def find( event_or_array )
      event, target = parse_destination(event_or_array)
      _args, _block = @args, @block
      returning binding.new_transition(event, target) do |t|
        t.apply!(&_block) if _block
        if _args
          t.args = _args 
        end
      end        
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
    
    #
    #
    #
    
    def singular
      result.first if result.length == 1
    end

    def next
      @options[:cyclic] ||= false
      singular
    end
    
    def next_state
      @options[:cyclic] ||= false
      if result.map(&:target).uniq.length == 1
        result.first.target
      end
    end

    def next_event
      @options[:cyclic] ||= false
      if result.map(&:event).uniq.length == 1
        result.first.event
      end
    end
    
    #
    #
    #

    def events
      map {|t| t.event }
    end

    def targets
      map {|t| t.target }
    end

    def apply! # (&block
      result.each { |t| t.apply &block if block }
    end

    def with(*args, &block)
      @args  = args
      @block = block
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
    # Result 
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

          # TODO hmm ... "sequences" ... delete this?
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
              ts << t if (t.valid? or !options[:valid])
            end
          end

        end
      end.flatten.extend(Result)
      
      if @args || @block
        @result.each do |t|
          t.apply!( &@block) if @block 
          t.args = @args     if @args
        end
      end
      
      @result
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

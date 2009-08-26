module StateFu
  class TransitionQuery
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

    def method_missing(method_name, *args, &block)
      if result.respond_to?(method_name, true)
        result.__send__(method_name, *args, &block)
      else
        super(method_name, *args, &block)
      end
    end
            
    #
    # 
    #
    
    # same as find, except that if there is more than one target for the event
    # and only one is valid, it will return that one.
    # def search(destination=nil, &block)
    #   # use the prepared event & target if none are supplied
    #   event, target = destination.nil? ? [options[:event], options[:target]] : parse_destination(destination)
    #   query         = for_event(event).to(target)
    #   query.find || query.valid.singular || NilTransition.new
    # end

    # find a transition by event and optionally (optional if it can be inferred) target.
    def find(destination=nil, &block)
      # use the prepared event & target if none are supplied
      event, target = destination.nil? ? [options[:event], options[:target]] : parse_destination(destination)
      _args, _block = @args, @block
      returning binding.new_transition(event, target) do |transition|
        # return NilTransition.new if transition.nil?
        transition.apply!(&_block) if _block
        if _args
          transition.args = _args 
        end
      end        
    end
    
    # def legal?(destination=nil, &block)
    #   # use the prepared event & target if none are supplied
    #   event, target = destination.nil? ? [options[:event], options[:target]] : parse_destination(destination)
    #   begin
    #     !!search(destination, &block)
    #   rescue IllegalTransition
    #     false
    #   end
    # end

    #
    #
    #     
    
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

    def for_event event
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
    
    def only_one
      result.first if result.length == 1
    end
    alias_method :singular, :only_one

    def only_one?
      !!singular
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
      @block = block if block_given?
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
    def parse_destination(destination)
      event, target = destination

      unless event.is_a?(Event)
        event = binding.machine.events[event]
      end
      
      unless target.is_a?(State)
        target = binding.machine.states[target] rescue nil
      end
        
      raise ArgumentError.new( [event,target].inspect ) unless
        [[Event, State],[Event, NilClass]].include?( [event,target].map(&:class) )
      [event, target]
    end # parse_destination

  end
end

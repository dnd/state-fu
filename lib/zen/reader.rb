module Zen
  class Reader

    attr_reader :koan

    def self.parse( koan, &block)
      reader = new( koan )
      reader.instance_eval( &block )
    end

    def initialize( koan )
      @koan = koan
    end

    def event( name, options={}, &block )
      name = name.to_sym
      options.symbolize_keys!
      if existing_event = koan.events[:name]
        existing_event.update!( options, &block)
      else
        new_event = Zen::Event.new( @koan, name, options, &block )
        koan.events << new_event
        new_event
      end
    end

    def state( *args, &block )
      options = args.extract_options!.symbolize_keys!
      args.each do |name|
        if existing_state = koan.states[name.to_sym]
          existing_state.update!(options, &block)
        else
          new_state = Zen::State.new( koan, name, options, &block )
          koan.states << new_state
          new_state
        end
      end
    end

  end
end

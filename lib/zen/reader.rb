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

    def state( *args, &block )
      options = args.extract_options!.symbolize_keys!
      args.each do |name|
        if existing_state = koan.states[name.to_sym]
          existing_state.update!(options, &block)
          existing_state
        else
          new_state = Zen::State.new( name, options, &block )
          koan.states << new_state
          new_state
        end
      end
    end

  end
end

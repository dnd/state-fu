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

    # event definition
    def event( name, options={}, &block )
      koan.define_event( name, options, &block )
    end

    def events( *args, &block )
      options = args.extract_options!.symbolize_keys!
      args.each { |name| event( name.to_sym, options, &block) }
    end

    # state definition
    def initial_state( *args, &block )
      koan.initial_state= state( *args, &block)
    end

    def state( name, options={}, &block )
      koan.define_state( name, options, &block )
    end

    def states( *args, &block )
      options = args.extract_options!.symbolize_keys!
      args.each { |name| state( name.to_sym, options, &block) }
    end

    def from *args
      raise "from(*origin, :to => *target) must be inside an event block"
    end

    def all_states *a, &b
      Logger.info "<Zen::Reader.all_states not implemented>"
    end
    # def from *args
    #
    # end
  end
end

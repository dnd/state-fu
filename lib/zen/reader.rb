module Zen
  class Reader

    attr_reader :koan

    def self.parse(koan, &block)
      reader = new( koan )
      reader.instance_eval( &block )
    end

    def initialize( koan )
      @koan = koan
    end

    def state( *args, &block )
      s = Zen::State.new( *args )
      # s.instance_eval &block
      koan.states << s
    end


  end
end

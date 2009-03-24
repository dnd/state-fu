module Zen
  class Phrase # Abstract Superclass of State & Event
    include Zen::Helper # define apply!

    attr_reader :koan, :name, :options, :hooks

    def initialize(koan, name, options={})
      @koan    = koan
      @name    = name.to_sym
      @options = options.symbolize_keys!
      @hooks   = Zen::Hooks.for( self )
    end

    # sneaky way to make some comparisons / duck typing a bit cleaner
    alias_method :to_sym,  :name

    def add_hook slot, name, value
      @hooks[slot.to_sym] << [name.to_sym, value]
    end

    def reader(options={}, &block)
      Zen::Reader.new( koan, self, options, &block )
    end

  end
end


module Zen
  class State

    attr_reader :name, :options

    # TODO - do something with options
    def initialize(name, options={}, &block)
      @name    = name.to_sym
      @options = options.symbolize_keys!
      yield self if block_given?
    end

    def update!( options={}, &block )
      @options.merge!( options.symbolize_keys! )
      instance_eval &block if block_given?
    end

  end
end

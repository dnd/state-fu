module Zen
  class Guard

    attr_reader :koan, :name, :message, :method_name, :options

    # Specifies a guard method to be called to check if a state can
    # be transitioned to.
    #
    # It will be executed in the context of the "disciple" object,
    # before any event is triggered. The named method should be a
    # symbol ending with '?', and should refer to an already defined
    # method.
    #
    # The named method will be called once for each candidate state,
    # with the state as the argument. A non-true return value will
    # prevent that state being transitioned to.
    def initialize( koan, name, options={}, &block )
      @options     = options.symbolize_keys!
      @koan        = koan
      @name        = name.to_sym
      @message     = @options.delete(:message)     || "#{name} was not satisfied."
      @method_name = @options.delete(:method_name) || @name
      @block       = block if block_given?
      Logger.warn("Guard method #@method_name does not end in '?'") unless
        @method_name.to_s[/\?$/]

      # Can't warn about undefined methods because we don't have a reference
      # we can follow
    end

    def select( *states, object )
      states.flatten.select do |state|
        if @block
          @block.call( state )
        else
          object.send( method_name, state )
        end
      end

    end

  end
end

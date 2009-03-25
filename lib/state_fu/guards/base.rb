module StateFu
  module Guards
    class Base
      include StateFu::Helper # define apply!
      attr_reader :machine, :name, :message, :method_name, :options

      def initialize( machine, name, options={}, &block )
        @options     = options.symbolize_keys!
        @machine        = machine
        @name        = name.to_sym
        @message     = @options.delete(:message)     || "#{name} was not satisfied."
        @method_name = @options.delete(:method_name) || @name
        @block       = block if block_given?
        Logger.warn("Guard method #@method_name does not end in '?'") unless
          @method_name.to_s[/\?$/]
      end

      def call( *args )
        method_ref = @block || method_name
        args       = limit_arguments( method_ref, args )
        case method_ref
        when Symbol
          transition.object.send( method_ref, args )
        when Proc
          transition.object.instance_eval do
            block.call( args )
          end
        end
      end

      def limit_arguments( method_ref, arguments )
        arity = case method_ref
                when Symbol
                  transition.object.method( method_ref )
                when Proc
                  method_ref
                end.arity
        arguments[ 0, arity ]
      end

    end
  end
end

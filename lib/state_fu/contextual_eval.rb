module StateFu

  # satanic incantations we use for evaluating blocks conditionally,
  # massaging their arguments and managing execution context.
  module ContextualEval
    # :nodoc:
    module InstanceMethods

      # if we use &block syntax it stuffs the arity up, so we have to
      # pass it as a normal argument. Ruby bug!
      def limit_arguments( block, *args )
        case block.arity
        when -1, 0
          nil
        else
          args[0 .. (block.arity - 1) ]
        end
      end

      def evaluate( *args, &proc )
        if proc.arity > 0
          args = limit_arguments( proc, *args )
          object.instance_exec( *args, &proc )
        else
          instance_eval( &proc )
        end
      end

      def call_on_object_with_optional_args( name, *args )
        if meth = object.method( name )
          args = limit_arguments( meth, *args )
          if args.nil?
            object.send( name )
          else
            object.send( name, *args )
          end
        else
          raise NoMethodError.new( "undefined method #{name} for #{object.inspect}" )
        end
      end

      def call_on_object_with_self( name )
        call_on_object_with_optional_args( name, self )
      end

      def evaluate_named_proc_or_method( name, *args )
        if (name.is_a?( Proc ) && proc = name) || proc = machine.named_procs[ name ]
          evaluate( *args, &proc )
        elsif self.respond_to?( name )
          if method(name).arity == 0
            send(name)
          else
            send(name, *args )
          end
          # evaluate( *args, &method(name) )
        elsif object.respond_to?( name )
          call_on_object_with_optional_args( name, *args )
        else # method is not defined
          if name.to_s =~ /^not_(.*)$/
            !evaluate_named_proc_or_method( $1, *args )
          else
            raise NoMethodError.new("#{name} is not defined on #{object} or #{self} or as a named proc in #{machine}")
          end
        end
      end

      def find_event_target( evt, tgt )
        case tgt
        when StateFu::State
          tgt
        when Symbol
          binding && binding.machine.states[ tgt ] # || raise( tgt.inspect )
        when NilClass
          evt.respond_to?(:target) && evt.target
        else
          raise ArgumentError.new( "#{tgt.class} is not a Symbol, StateFu::State or nil (#{evt})" )
        end
      end
    end

    def self.included( klass )
      klass.send :include, InstanceMethods
    end
  end
end
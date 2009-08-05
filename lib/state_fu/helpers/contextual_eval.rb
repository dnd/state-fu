module StateFu

  # satanic incantations we use for evaluating blocks conditionally,
  # massaging their arguments and managing execution context.
  module ContextualEval
    # :nodoc:
    module InstanceMethods

      # Truncates an argument list to match the arity of a given block.
      #
      # if we use &block syntax it modifies the arity, so we have to
      # pass it as a reference-style argument - Ruby bug (!).
      def limit_arguments( block, *args )
        case block.arity
        when -1, 0
          nil
        else
          args[0 .. (block.arity - 1) ]
        end
      end

      # execute a block with the given arguments in a context depending on its arity.
      #
      # If the block takes one or more arguments, execute it in the context of self.object
      # and pass it the arguments (which will be a Transition, providing a convenient bundle of 
      # execution context).
      
      # If the block takes no arguments, execute it in the context of self (a Binding or Transition);
      # access to .object is possible through (self.)object
    
      # def binding_or_transition_eval *args, &block
      
      def evaluate( *args, &proc )
        if proc.arity > 0
          args = limit_arguments( proc, *args )
          object.instance_exec( *args, &proc )
        else
          instance_eval( &proc )
        end
      end

      # call the named method on self.object, using send; limit the argument
      # list's length according to what the method expects.
      #
      # TODO rename to something snappier
      #
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

      # call the named method on self.object, passing self as the sole argument
      #
      # def call_on_object_with_self( name )
      #   call_on_object_with_optional_args( name, self )
      # end

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
            
    end # InstanceMethods

    def self.included( klass )
      klass.send :include, InstanceMethods
    end
  end
end
module StateFu    
  # a home for methods / behaviour shared by Transition and MockTransition.

  module Transitive
    module InstanceMethods
      
      # resolve the target for the given event as a StateFu::State either from
      # the given target if it's already a State, or it's name, or the
      # (single, simple) target of the given event.
      
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

    module ClassMethods
    end

    def self.included( mod )
      mod.send( :include, InstanceMethods )
      mod.extend( ClassMethods )
    end
  end
end

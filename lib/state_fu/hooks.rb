module StateFu
  module Hooks

    ALL_HOOKS = [[:event,  :before],   # good place to start a transaction, etc
                 [:origin, :exit],     # say goodbye!
                 [:event,  :execute],  # do stuff here, as a rule of thumb
                 [:target, :entry],    # last chance to halt!
                 [:event,  :after],    # clean up all the mess
                 [:target, :accepted]] # state changed. Quicksave!

    EVENT_HOOKS = ALL_HOOKS.select { |type, name| type == :event }
    STATE_HOOKS = ALL_HOOKS - EVENT_HOOKS
    HOOK_NAMES  = ALL_HOOKS.map {|a| a[1] }

    # just turn the above into what each class needs
    # and make it into a nice hash: { :name =>[ hook, ... ], ... }
    def self.for( me )
      x = if    me.is_a?( StateFu::State ); STATE_HOOKS
          elsif me.is_a?( StateFu::Event ); EVENT_HOOKS
          else  {}
          end.
        map { |_,name| [name, [].extend( StateFu::OrderedHash )] }
      hash = x.inject({}) {|h, a| h[a[0]] = a[1] ; h}
      hash.extend( StateFu::OrderedHash ).freeze
    end

  end
end

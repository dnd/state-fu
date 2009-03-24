module Zen
  module Hooks

    ALL_HOOKS = [[:event,  :before],   # good place to start a transaction, etc
                 [:origin, :exit],     # say goodbye!
                 [:event,  :execute],  # do stuff here, as a rule of thumb
                 [:target, :entry],    # last chance to halt!
                 [:event,  :after],    # clean up all the mess
                 [:target, :accepted]] # state changed. Quicksave!

    EVENT_HOOKS = ALL_HOOKS.select { |type, name| type == :event }
    STATE_HOOKS = ALL_HOOKS - EVENT_HOOKS

    # just turn the above into what each class needs
    # and make it into a nice hash of { :name => [hook, ... ], ... }
    def self.for( me )
      x = if me.is_a?(Zen::State)
            STATE_HOOKS
          elsif me.is_a?(Zen::Event)
            EVENT_HOOKS
          else
            {}
          end.map {|k,v| [v, [].extend(Zen::OrderedHash) ] }
      Hash[x].extend(Zen::OrderedHash).freeze
    end

  end
end

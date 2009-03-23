module Zen
  module Hooks

    ALL_HOOKS = [[:event,  :before],
                 [:origin, :exit],
                 [:event,  :execute],
                 [:target, :entry],
                 [:event,  :after],    # cannot halt here
                 [:target, :accepted]] # cannot halt here

    EVENT_HOOKS = ALL_HOOKS.select { |type, name| type == :event }
    STATE_HOOKS = ALL_HOOKS - EVENT_HOOKS

    def self.for( me )
      x = if me.is_a?(Zen::State)
            STATE_HOOKS
          elsif me.is_a?(Zen::Event)
            EVENT_HOOKS
          else
            {}
          end.map {|k,v| [v, [].extend(Zen::Helper::OrderedHash) ] }

      Hash[x].extend(Zen::Helper::OrderedHash).freeze
    end
  end
end

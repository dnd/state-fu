module Zen
  class Event
    # DRY up duplicated code
    include Zen::Interfaces::Event

    def from *args, &block
      options = args.extract_options!.symbolize_keys!
      initial_state_names = args.flatten.map(&:to_sym)
      target_state_name   = options.symbolize_keys!.delete(:to)
      [initial_state_names, target_state_name].flatten.each do |name|
        unless state = koan.states[name]
          koan.states << Zen::State.new( koan, name )
        end
      end
    end

  end

end

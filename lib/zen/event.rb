module Zen
  class Event
    attr_reader :origins
    attr_reader :targets

    # DRY up duplicated code
    include Zen::Interfaces::Event

    # from :origin_1, :origin_2, ... :to => :target
    # from :origin_1, :origin_2, ... :to => [:target_1, :target_2]
    def from *args, &block
      options   = args.extract_options!.symbolize_keys!
      _origins  = args.flatten.map(&:to_sym)
      _targets  = options.symbolize_keys!.delete(:to)
      [_origins, _targets].each do |arg|
      end
      [_origins, _targets].flatten.each do |name|
        unless state = koan.states[name]
          koan.states << Zen::State.new( koan, name ) # options, &block omitted
        end
      end
    end

    def origin_names
    end

    def target_names
    end

    def origin_name
    end

    def target_name
    end

    def simple?
      true
    end

  end

end

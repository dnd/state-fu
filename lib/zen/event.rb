module Zen
  class Event
    # DRY up duplicated code
    include Zen::Interfaces::Event

    def from *a, &b
      puts "yay"
    end
  end

end

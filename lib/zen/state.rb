module Zen
  class State < Zen::Phrase


    #
    # Proxy methods to Zen::Reader
    #
    def event *a, &b
      reader.event( *a, &b )
    end

  end
end

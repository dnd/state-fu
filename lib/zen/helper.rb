module Zen

  # TODO clean up structure

  # retrieve by name
  module StateOrEventArray

    def []( idx )
      begin
        super( idx )
      rescue TypeError => e
        if idx.respond_to?(:to_sym)
          self.detect { |i| i.respond_to?(:name) && i.name == idx.to_sym }
        else
          raise e
        end
      end
    end

    def names
      map(&:name)
    end

  end

  module StateArray
    include StateOrEventArray

    def from( origin, include_dynamic = false )
      select { |e| e.respond_to?(:from?) && e.from?( origin, include_dynamic ) }
    end

    def to( target, include_dynamic = false )
      select { |e| e.respond_to?(:to?) && e.to?( target, include_dynamic ) }
    end

    def dynamic
      select { |e| e.respond_to?(:dynamic?) && e.dynamic? }
    end

  end

  module EventArray
    include StateOrEventArray

    def from( origin )
      select { |e| e.respond_to?(:from?) && e.from?( origin ) }
    end

    def to( target )
      select { |e| e.respond_to?(:to?) && e.to?( target ) }
    end
  end


  module Helper
    module OrderedHash
      def []( index )
        begin
          super( index )
        rescue TypeError
          ( x = self.detect { |i| i.first == index }) && x[1]
        end
      end

      def []=( index, value )
        begin
          super( index, value )
        rescue TypeError
          ( x = self.detect { |i| i.first == index }) ?
          x[1] = value : self << [ index, value ].extend( OrderedHash )
        end
      end

      def keys
        map(&:first)
      end

      def values
        map(&:last)
      end

    end  # OrderedHash
  end    # Helper
end      # Zen

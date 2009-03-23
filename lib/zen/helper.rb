module Zen

  module ArraySmartIndex
    def []( index )
      begin
        super( index )
      rescue TypeError
        self.detect do |i|
          i.name == index.to_sym
        end if index.respond_to?(:to_sym)
      end
    end
  end  # ArrayNameAccessor


  module Helper
    module OrderedHash
      def []( index )
        begin
          super( index )
        rescue TypeError
          x = self.detect do |i|
            i.first == index
          end # if index.class ...
          x && x[1]
        end
      end

      def []=( index, value )
        begin
          super( index, value )
        rescue TypeError
          x = self.detect do |i|
            i.first == index
          end # if index.class ...
          if x
            x[1] = value
          else
            self << [index, value].extend(OrderedHash)
          end
        end
      end

      def keys
        map(&:first)
      end

      def values
        map(&:last)
      end
    end  # OrderedHash
  end

end

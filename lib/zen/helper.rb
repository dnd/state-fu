module Zen
  module Helper

    module InstanceMethods

      def apply!( options={}, &block )
        @options.merge!( options.symbolize_keys! )
        return self unless block_given?
        case block.arity
        when 1     # lambda{ |state| ... }.arity
          yield self
        when -1, 0 # lambda{ }.arity ( -1 in ruby 1.8.x but 0 in 1.9.x )
          instance_eval &block
        end
        self
      end
      alias_method :update!, :apply!
    end

    module ClassMethods
    end

    def self.included( mod )
      mod.send( :include, InstanceMethods )
      mod.extend( ClassMethods )
    end

  end

  # Use modules to extend Hash / Array instances.
  # This allows us to add custom accessors to collections of objects
  module StateOrEventArray
    # Pass a symbol to the array and get the object with that .name
    # [<Foo @name=:bob>][:bob]
    # => <Foo @name=:bob>
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
    # Unlike most implementations, this extends Array. It's small,
    # though won't be very fast on lookup with many items. Internally
    # objects are stored as a list of [:key, 'value'] pairs.
    module OrderedHash
      # if given a symbol / string, return the
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

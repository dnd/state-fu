module Zen
  class Space
    cattr_reader :named_koans, :class_koans, :field_names

    # class_koans[ Class ][ method_name ] # => a Zen::Koan
    # class_koans[ Klass ][ nil ]         # => the Klass's default Koan
    # class_koans[ Klass ].om             # => the Klass's default Koan
    # field_names[ Class ][ method_name ] # => name of persistence field

    LAZY_HASH = lambda do |h, k|
      m = Module.new do
        def om; self[Zen::DEFAULT_KOAN]; end;
      end
      if k.nil? && k = self[Zen::DEFAULT_KOAN]
        k
      else
        h[k]= Hash.new().extend( m )
      end
    end

    def self.inject!( klass, koan, name, field_name )
      name                       = name.to_sym
      field_name                 = field_name.to_sym
      if @@class_koans[klass][name]
        raise("#{klass} already knows a Koan #{koan} by the name #{name}.")
      else
        @@class_koans[klass][name] = koan
        @@field_names[klass][name] = field_name
      end
    end

    class << self
      def beginners_mind!
        @@named_koans = Hash.new
        @@class_koans = Hash.new( &LAZY_HASH )
        @@field_names = Hash.new( &LAZY_HASH )
      end
      alias_method :reset!,  :beginners_mind!
      alias_method :forget!, :beginners_mind!
    end
    beginners_mind!
  end
end

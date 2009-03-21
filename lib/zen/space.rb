module Zen
  class Space
    cattr_accessor :named_koans, :class_koans, :bindings

    # hash[ Klass ][ nil ] # => return the Klass's default
    # hash[ Klass ].om     # => return the Klass's default
    module LazyHash
      def om; self[Zen::DEFAULT_KOAN]; end;
      def om; self[Zen::DEFAULT_KOAN]; end;
    end
    LAZY_HASH = lambda do |h, k|
      if k.nil? && x = self[Zen::DEFAULT_KOAN]
        x
      else
        h[k]= Hash.new().extend( LazyHash )
      end
    end

    class << self
      def forget!
        @@named_koans = Hash.new
        @@class_koans = Hash.new( &LAZY_HASH )
        @@bindings    = Hash.new( &LAZY_HASH )
      end
      alias_method :reset!,          :forget!
      alias_method :init!,           :forget!
      alias_method :beginners_mind!, :forget!
    end

    beginners_mind!
  end
end

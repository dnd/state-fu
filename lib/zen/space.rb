module Zen
  class Space

    cattr_accessor :named_koans, :class_koans

    # class_koans[ Class ][ method_name ] # => a Zen::Koan
    # class_koans[ Klass ][ nil ]         # => the Klass's default Koan
    # class_koans[ Klass ].om             # => the Klass's default Koan
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

    class << self
      def beginners_mind!
        @@named_koans = Hash.new
        @@class_koans = Hash.new( &LAZY_HASH )
      end
      alias_method :reset!,          :beginners_mind!
    end
    beginners_mind!
  end
end

module Zen
  class Space
    cattr_accessor :named_koans, :class_koans, :bindings

    module HashDefault; def om; self[Zen::DEFAULT_KOAN]; end; end

    LAZY_HASH = lambda { |h, k| h[k]= Hash.new().extend( HashDefault ) }

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

module Zen
  # Provides a place to stash references.
  # In most cases you won't need to access it directly, though
  # calling reset! before each of your tests/specs can be helpful.
  class Space
    cattr_reader :named_koans, :class_koans, :field_names

    # class_koans[ Class ][ method_name ] # => a Zen::Koan
    # class_koans[ Klass ][ nil ]         # => the Klass's default Koan
    # field_names[ Class ][ method_name ] # => name of attribute / db field

    # return the default koan, or an empty hash, given a missing index.
    LAZY_HASH = lambda do |h, k|
      if k.nil?
        self[ Zen::DEFAULT_KOAN ]
      else
        h[k]= Hash.new()
      end
    end

    # Add a koan to Zen::Space and register it with a given class, by a given name.
    def self.insert!( klass, koan, name, field_name )
      name                       = name.to_sym
      field_name                 = field_name.to_sym
      existing_koan              = @@class_koans[klass][name]
      if existing_koan && !existing_koan.empty?
        raise("#{klass} already knows a non-empty Koan #{koan} by the name #{name}.")
      else
        @@class_koans[klass][name] = koan
        @@field_names[klass][name] = field_name
      end
    end
    class << self
      alias_method :insert,  :insert!
    end

    # Clears all koans and their bindings to classes.
    # Also initializes the hashes we use to store our references.
    def self.beginners_mind!
      @@named_koans = Hash.new
      @@class_koans = Hash.new( &LAZY_HASH )
      @@field_names = Hash.new( &LAZY_HASH )
    end
    class << self
      alias_method :reset!,  :beginners_mind!
      alias_method :forget!, :beginners_mind!
    end
    beginners_mind!
  end
end

module StateFu
  # Provides a place to stash references.
  # In most cases you won't need to access it directly, though
  # calling reset! before each of your tests/specs can be helpful.
  class FuSpace
    cattr_reader :named_machines, :class_machines, :field_names

    # class_machines[ Class ][ method_name ] # => a StateFu::Machine
    # class_machines[ Klass ][ nil ]         # => the Klass's default Machine
    # field_names[ Class ][ method_name ] # => name of attribute / db field

    # return the default machine, or an empty hash, given a missing index.
    LAZY_HASH = lambda do |h, k|
      if k.nil?
        self[ StateFu::DEFAULT_MACHINE ]
      else
        h[k]= Hash.new()
      end
    end

    # Add a machine to StateFu::FuSpace and register it with a given class, by a given name.
    def self.insert!( klass, machine, name, field_name )
      name                       = name.to_sym
      field_name                 = field_name.to_sym
      existing_machine              = @@class_machines[klass][name]
      if existing_machine && !existing_machine.empty?
        raise("#{klass} already knows a non-empty Machine #{machine} by the name #{name}.")
      else
        @@class_machines[klass][name] = machine
        @@field_names[klass][name] = field_name
      end
    end
    class << self
      alias_method :insert,  :insert!
    end

    # Clears all machines and their bindings to classes.
    # Also initializes the hashes we use to store our references.
    def self.beginners_mind!
      @@named_machines = Hash.new
      @@class_machines = Hash.new( &LAZY_HASH )
      @@field_names = Hash.new( &LAZY_HASH )
    end
    class << self
      alias_method :reset!,  :beginners_mind!
      alias_method :forget!, :beginners_mind!
    end
    beginners_mind!
  end
end

module StateFu
  # Provides a place to stash references.
  # In most cases you won't need to access it directly, though
  # calling reset! before each of your tests/specs can be helpful.
  class FuSpace
    cattr_reader :machines, :field_names

    # return the default machine, or an empty hash, given a missing index.
    #
    # * machines[ Klass ][ nil ]               # => Klass's default Machine
    # * machines[ Klass ][ :status ]           # => Klass's :status Machine    
    # * field_names[ Class ][ method_name ]    # => name of attribute / db field
    #
    LAZY_HASH = lambda do |h, k|
      if k.nil?
        self[ StateFu::DEFAULT_MACHINE ]
      else
        h[k]= Hash.new()
      end
    end

    def self.machines
      @@machines
    end

    # make it so that a class which has included StateFu has a binding to
    # this machine
    def self.bind!( machine, owner, name, field_name)
      insert!( owner, machine, name, field_name )
      # method_missing to catch NoMethodError for event methods, etc
      StateFu::MethodFactory.prepare_class( owner )

      # define an accessor method with the given name
      if owner.class == Class 
        unless owner.respond_to?(name)       
          owner.class_eval do
            define_method name do
              state_fu( name )
            end
          end
        end   
        # prepare the persistence field
        StateFu::Persistence.prepare_field( owner, field_name )
      else 
        # singleton machines
        raise NotImplementedError, "StateFu::FuSpace doesn't support singleton machines yet"
        #
        # prepare the eigenclass ?
        #             
      end 
    end

    # Add a machine to StateFu::FuSpace and register it with a given class, by a given name.
    # Binds a machine to a class, with a given name and field_name
    def self.insert!( owner, machine, name, field_name )
                            name = name.to_sym
         @@machines[owner][name] = machine 
      @@field_names[owner][name] = field_name.to_sym
    end
          
    # Clears all machines and their bindings to classes.
    # Also initializes the hashes we use to store our references.
    def self.reset!
      @@machines    = Hash.new( &LAZY_HASH )
      @@field_names = Hash.new( &LAZY_HASH )
    end
    class << self
      alias_method :init!, :reset!
    end 
    
    init!
    
  end
end

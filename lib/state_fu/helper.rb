module StateFu

  # Utilities and snippets
  module Helper

    # Instance methods mixed in on inclusion of StateFu::Helper
    module InstanceMethods

      # if given a hash of options (or a splatted arglist containing
      # one), merge them into @options. If given a block, eval it
      # (yielding self if the block expects it)
      def apply!( options={}, &block )
        options.respond_to?(:keys) || options = options.extract_options!
        @options.merge!( options.symbolize_keys! )
        return self unless block_given?
        case block.arity
        when 1     # lambda{ |state| ... }
          yield self
        when -1, 0 # lambda{ } ( -1 in ruby 1.8.x but 0 in 1.9.x )
          instance_eval &block
        else
          raise ArgumentError, "unexpected block arity: #{block.arity}"
        end
        self
      end
      alias_method :update!, :apply!

    end

    # Class methods mixed in on inclusion of StateFu::Helper
    module ClassMethods
    end

    def self.included( mod )
      mod.send( :include, InstanceMethods )
      mod.extend( ClassMethods )
    end

  end

  # Stuff shared between StateArray and EventArray
  module ArrayWithSymbolAccessor
    # Pass a symbol to the array and get the object with that .name
    # [<Foo @name=:bob>][:bob]
    # => <Foo @name=:bob>
    def []( idx )
      begin
        super( idx )
      rescue TypeError => e
        if idx.respond_to?(:to_sym)
          self.detect { |i| i == idx || i.respond_to?(:name) && i.name == idx.to_sym }
        else
          raise e
        end
      end
    end

    # so we can go Machine.states.names
    # mildly helpful with irb + readline
    def names
      map(&:name)
    end

    # SPECME
    def except *syms
      reject {|el| syms.flatten.compact.map(&:to_sym).include?(el.to_sym) } #.extend ArrayWithSymbolAccessor
    end

    def only *syms
      select {|el| syms.flatten.compact.map(&:to_sym).include?(el.to_sym) } #.extend ArrayWithSymbolAccessor
    end

  end

  # Array extender. Used by Machine to keep a list of states.
  module StateArray
    include ArrayWithSymbolAccessor

    # is there exactly one possible event to fire, with a single
    # target event?
    def next?
    end

    # if next?, return the state
    def next
    end

  end

  # Array extender. Used by Machine to keep a list of events.
  module EventArray
    include ArrayWithSymbolAccessor

    # return all events transitioning from the given state
    def from( origin )
      select { |e| e.respond_to?(:from?) && e.from?( origin ) }
    end

    # return all events transitioning to the given state
    def to( target )
      select { |e| e.respond_to?(:to?) && e.to?( target ) }
    end

    # is there exactly one possible event to fire, with a single
    # target event?
    def next?
    end

    # if next?, return the event
    def next
    end

  end

  # Array extender. Used by Machine to keep a list of helpers to mix into
  # context objects.
  module HelperArray

  end

  # Extend an Array with this. It's a fairly compact implementation,
  # though it won't be super fast with lots of elements.
  # items. Internally objects are stored as a list of
  # [:key, 'value'] pairs.
  module OrderedHash
    # if given a symbol / string, treat it as a key
    def []( index )
      begin
        super( index )
      rescue TypeError
        ( x = self.detect { |i| i.first == index }) && x[1]
      end
    end

    # hash-style setter
    def []=( index, value )
      begin
        super( index, value )
      rescue TypeError
        ( x = self.detect { |i| i.first == index }) ?
        x[1] = value : self << [ index, value ].extend( OrderedHash )
      end
    end

    # poor man's Hash.keys
    def keys
      map(&:first)
    end

    # poor man's Hash.values
    def values
      map(&:last)
    end
  end  # OrderedHash

  module ContextualEval
    module InstanceMethods
      def evaluate( &proc )
        if proc.arity == 1
          object.instance_exec( self, &proc )
        else
          instance_eval( &proc )
        end
      end

      def evaluate_named_proc_or_method( name )
        if proc = machine.named_procs[ name ]
          evaluate &proc
        else
          if object.method(name).arity == 1
            object.send( name, self )
          else
            object.send( name )
          end
        end
      end
    end

    def self.included( klass )
      klass.send :include, InstanceMethods
    end
  end
end

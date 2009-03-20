module Zen
  #
  #
  class Koan
    include Helper

    # access koans by name in global space - mainly for sharing koans
    # between classes
    def self.[] name, options, &block
      # ...
    end

    # meta-constructor; expects to be called via Klass.koan()
    def self.for_class(klass, name, options, &block)
      name = name.to_sym
      koan = Zen::Space.class_koans()[ klass ][ name ]
      if block_given?
        if koan
          puts koan.inspect
          koan.learn!( &block )
        else
          koan = new( name, options, &block )
          koan.teach!( klass, name, options )
          koan
          # => Zen::Binding.new( klass, name, koan, options )
        end
      else # no block
        koan
      end
    end

    def self.meditate_on()
    end

    ##
    ##

    def initialize( *a, &block )
    end

    def learn!( &block )
      puts koan.inspect + " learnt"
    end
    alias_method :merge!, :learn!
    alias_method :merge, :learn!
    alias_method :parse!, :learn!
    alias_method :parse, :learn!

    # the Koan will instruct the klass.
    def teach!( klass, method_name, options=DEFAULT_OPTIONS )
      Zen::Binding.new( klass, method_name, self, options )
    end
    alias_method :bind!, :teach!
    alias_method :install!, :teach!
    alias_method :meditate!, :teach!

    protected
    def self.valid_indexes?(  )
    end

    def self.extract_index *a
      name = nil
      if validate_name(a) # [MyClass, :mylabel]
        name = a
      elsif a.length == 0
        name = [self, DEFAULT_LABEL]
      elsif a.length == 1
        arg = a.first
        if arg.is_a?( Class )
          name = [arg, DEFAULT_LABEL]
        elsif [Symbol].include?( arg.class )
          name = [self, arg]
        end
      end
      raise name.inspect unless name.nil? || validate_name( name )
      name
    end

  end
end

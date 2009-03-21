module Zen
  #
  #
  class Koan
    include Helper

    # analogous to self.for_class, but keeps koans in
    # global space, not tied to a specific class.
    def self.[] name, options, &block
      # ...
    end

    # meta-constructor; expects to be called via Klass.koan()
    def self.for_class(klass, name, options, &block)
      options.symbolize_keys!
      name = name.to_sym
      koan = Zen::Space.class_koans[ klass ][ name ]
      if block_given?
        if koan
          puts koan.inspect
          koan.learn!( &block )
        else
          koan = new( name, options, &block )
          koan.teach!( klass, name, options[:field_name] )
          koan
        end
      else
        koan
      end
    end

    def initialize( *a, &block )
    end

    # merge the commands in &block with the existing koan
    def learn!( &block )
      puts koan.inspect + " learnt"
    end
    alias_method :merge!, :learn!
    alias_method :merge, :learn!
    alias_method :parse!, :learn!
    alias_method :parse, :learn!

    # the Koan teaches a class how to meditate on it:
    def teach!( klass, name=Zen::DEFAULT_KOAN, field_name = nil )
      field_name ||= name.to_s.downcase.tr(' ', '_') + "_state"
      field_name   = field_name.to_sym
      Zen::Space.inject!( klass, self, name, field_name )
    end
    alias_method :bind!, :teach!
  end
end

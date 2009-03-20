require 'core_ext'
require 'helper'
require 'binding'
require 'space'
require 'koan'

module Zen

  class Meditation
    def initialize *a, &block
      # puts "Ommmmmmmmmmm"
    end
  end

  DEFAULT_OPTIONS = { :meta => {} }
  DEFAULT_KOAN    = :om
  LAZY_HASH       = lambda do |h, k|
      om = Module.new do
        def om
          self[Zen::DEFAULT_KOAN]
        end
      end
    h[k]= Hash.new().extend( om )
  end

  def self.included( klass )
    klass.extend ClassMethods
    klass.send( :include, InstanceMethods )
  end

  module ClassMethods
    def koan( name=Zen::DEFAULT_KOAN, options=Zen::DEFAULT_OPTIONS, &block )
      Zen::Koan.for_class( self, name, options, &block )
    end

    def koans( name=nil )
      name && name.to_sym
      if name
        Zen::Space.class_koans[self][name.to_sym]
      else
        Zen::Space.class_koans[self]
      end
    end
  end

  module InstanceMethods

    def om( name=Zen::DEFAULT_KOAN )
      name = name.to_sym
      if binding = Zen::Space.bindings[self.class][name]
        @om       ||= {}
        @om[name] ||= Zen::Meditation.new( binding, self )
        @om[name]
      end
    end

    def meditations()
      Zen::Space.class_koans[self.class]
    end

  end

  #
  #

  class Path
  end

end

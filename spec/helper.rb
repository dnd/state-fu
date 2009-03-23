#!/usr/bin/env ruby
thisdir = File.expand_path(File.dirname(__FILE__))
$: << thisdir << "#{thisdir}/../lib"

require 'rubygems'
require 'spec'
require 'zen-koan'

module ZenMatchers
  class HaveStatesMatcher
  end
end

module MySpecHelper

  def make_pristine_class(class_name, reset_first = false)
    reset! if reset_first
    @class_names ||= []
    @class_names << class_name
    klass = Class.new
    klass.send( :include, Zen )
    Object.send(:remove_const, class_name ) if Object.const_defined?( class_name )
    Object.const_set(class_name, klass)
  end

  def reset!
    @class_names ||= []
    @class_names.each do |class_name|
      Object.send(:remove_const, class_name ) if Object.const_defined?( class_name )
    end
    @class_names = []
    Zen::Space.reset!
  end

end

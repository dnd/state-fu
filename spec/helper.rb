$:.unshift(File.expand_path("#{File.dirname(__FILE__)}/../lib"))
require 'rubygems'
require 'spec'

require 'zen-koan'

$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

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
    @class_names.each do |n|
      Object.send(:remove_const, class_name ) if Object.const_defined?( class_name )
    end
    @class_names = []
    Zen::Space.reset!
  end

end

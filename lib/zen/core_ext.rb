require 'rubygems'


require 'active_support/core_ext/array'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
# require 'active_support/core_ext/string'

class Symbol
  unless instance_methods.include?(:'<=>')
    Logger.debug "monkeypatching Symbol <=> for ruby 1.8.x"
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end


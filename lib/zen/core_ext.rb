require 'rubygems'

require 'active_support/core_ext/hash'
require 'active_support/core_ext/array'
require 'active_support/core_ext/class'
require 'active_support/core_ext/blank'

# for ruby 1.8.x
class Symbol
  unless instance_methods.include?(:'<=>')
    puts "monkeypatching symbol"
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end

if Object.const_get("ActiveSupport").nil?
  # patch in what we need
end

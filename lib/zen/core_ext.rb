require 'rubygems'

# todo : remove this once its exclusion no longer breaks anything on any platforms
require 'activesupport'

require 'active_support/core_ext/array'
require 'active_support/core_ext/blank'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
# require 'active_support/core_ext/string'

class Symbol
  unless instance_methods.include?(:'<=>')
    # Logger.log ..
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end


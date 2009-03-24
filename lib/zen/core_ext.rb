require 'rubygems'

unless Object.const_defined?('ActiveSupport')

  require 'active_support/core_ext/array'
  require 'active_support/core_ext/blank'
  require 'active_support/core_ext/class'
  require 'active_support/core_ext/module'
  require 'active_support/core_ext/hash/keys'

  class Hash #:nodoc:
    include ActiveSupport::CoreExtensions::Hash::Keys
  end
end

class Symbol
  unless instance_methods.include?(:'<=>2')
    # Logger.log ..
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end

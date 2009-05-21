require 'rubygems'

class Symbol
  unless instance_methods.include?(:'<=>')
    # Logger.log ..
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end

unless Object.const_defined?('ActiveSupport')

  require 'active_support/core_ext/array'
  require 'active_support/core_ext/blank'
  # require 'active_support/core_ext/class'
  # require 'active_support/core_ext/module'
  require 'active_support/core_ext/hash/keys'

  as_lite_dir = File.join(File.dirname( __FILE__), 'active_support_lite' )

  Dir[File.join(File.dirname( __FILE__), 'active_support_lite','**' )].each do |lib|
    require lib
  end

  class Hash #:nodoc:
    include ActiveSupport::CoreExtensions::Hash::Keys
  end

end

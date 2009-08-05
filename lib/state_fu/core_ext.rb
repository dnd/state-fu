require 'rubygems'

# ruby1.9 style symbol comparability for ruby1.8
class Symbol  # :nodoc:
  unless instance_methods.include?(:'<=>')
    def <=> other
      self.to_s <=> other.to_s
    end
  end
end

# if ActiveSupport is absent, install a very small subset of it for
# some convenience methods
unless Object.const_defined?('ActiveSupport') # :nodoc:
  Dir[File.join(File.dirname( __FILE__), 'active_support_lite','**' )].sort.each do |lib|
    next unless File.file?( lib )
    require lib
  end

  class Hash #:nodoc:
    include ActiveSupport::CoreExtensions::Hash::Keys
  end
end

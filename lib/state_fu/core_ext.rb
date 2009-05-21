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

  as_lite_dir = File.join(File.dirname( __FILE__), 'active_support_lite' )

  Dir[File.join(File.dirname( __FILE__), 'active_support_lite','**' )].sort.each do |lib|
    next unless File.file?( lib )
    puts lib
    require lib
  end

  class Hash #:nodoc:
    include ActiveSupport::CoreExtensions::Hash::Keys
  end

end

require 'rubygems'

# if ActiveSupport is absent, install a very small subset of it for
# some convenience methods
unless Object.const_defined?('ActiveSupport')  #:nodoc
  Dir[File.join(File.dirname( __FILE__), 'active_support_lite','**' )].sort.each do |lib|
    next unless File.file?( lib )
    require lib
  end

  class Hash #:nodoc
    include ActiveSupport::CoreExtensions::Hash::Keys
  end
end

# ruby1.9 style symbol comparability for ruby1.8
if RUBY_VERSION < "1.9"
  class Symbol   #:nodoc
    unless instance_methods.include?(:'<=>')
      def <=> other
        self.to_s <=> other.to_s
      end
    end
  end
end

module ArrayToHash
  def to_h
    if RUBY_VERSION >= '1.8.7'
      Hash[self]
    else
      inject({}) { |h, a| h[a.first] = a.last; h }
    end
  end
end

class Array
  include ArrayToHash unless instance_methods.include?(:to_h)
end

class Object

  def self.__define_method( method_name, &block )
    self.class.class_eval do
      define_method method_name, &block
    end
  end

  def __define_singleton_method( method_name, &block )
    (class << self; self; end).class_eval do
      define_method method_name, &block
    end
  end


  def with_methods_on(other)
    (class << self; self; end).class_eval do
      # we need some accounting to ensure that everything behaves itself when
      # .with_methods_on is called more than once.
      @_with_methods_on ||= []
      if !@_with_methods_on.include?("method_missing_before_#{other.__id__}")
        alias_method "method_missing_before_#{other.__id__}", :method_missing
      end     
      @_with_methods_on << "method_missing_before_#{other.__id__}"
        
      define_method :method_missing do |method_name, *args|
        if _other.respond_to?(method_name, true)
          _other.__send__( method_name, *args )
        else
          send "method_missing_before_#{other.__id__}", method_name, *args
        end
      end      
    end

    result = yield

    (class << self; self; end).class_eval do
      # heal the damage
      if @_with_methods_on.pop != "method_missing_before_#{other.__id__}"
        raise "there is no god"
      end        
      if !@_with_methods_on.include?("method_missing_before_#{other.__id__}")
        alias_method :method_missing, "method_missing_before_#{other.__id__}"
        undef_method "method_missing_before_#{other.__id__}"
      end     
    end

    result
  end # with_methods_on
end


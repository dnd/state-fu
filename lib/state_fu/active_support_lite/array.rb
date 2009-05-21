#require 'array/access'
#require 'array/conversions'
require File.join( File.dirname( __FILE__),'array/extract_options')
require File.join( File.dirname( __FILE__),'array/grouping')
#require 'random_access'
#require 'wrapper'

class Array #:nodoc:
 # include ActiveSupport::CoreExtensions::Array::Access
 # include ActiveSupport::CoreExtensions::Array::Conversions
  include ActiveSupport::CoreExtensions::Array::ExtractOptions
  include ActiveSupport::CoreExtensions::Array::Grouping
 # include ActiveSupport::CoreExtensions::Array::RandomAccess
 # extend ActiveSupport::CoreExtensions::Array::Wrapper
end

require File.join( File.dirname( __FILE__),'array/extract_options')
require File.join( File.dirname( __FILE__),'array/grouping')

class Array #:nodoc:
  include ActiveSupport::CoreExtensions::Array::ExtractOptions
  include ActiveSupport::CoreExtensions::Array::Grouping
end

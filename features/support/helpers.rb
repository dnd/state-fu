def store_result( result )
  @result = result
  klass = result.is_a?( Class ) ? result : result.class
end

def store_object( object, &block )
  ivar = '@' + object.class.to_s.split('::').last.downcase
  yield object if block_given?
  instance_variable_set( ivar, object)
end

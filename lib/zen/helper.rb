module Zen

  module ArraySmartIndex
    def []( index )
      begin
        super( index )
      rescue TypeError
        self.detect do |i|
          i.name == index.to_sym
        end if index.respond_to?(:to_sym)
      end
    end
  end  # ArrayNameAccessor
  #
  #
  module Helper
    def assert_argument_type( arg, *valid_types )
    end
  end

end

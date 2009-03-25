module StateFu
  module Persistence

    def self.active_record_column?( obj, field_name )
      klass = obj.class
      Object.const_defined?("ActiveRecord") &&
        ::ActiveRecord.const_defined?("Base") &&
        klass.ancestors.include?( ::ActiveRecord::Base ) &&
        klass.columns.map(&:name).include?( field_name.to_s )
    end

    def self.for( binding, field_name )
      if active_record_column?( binding.machinist, field_name )
        self::ActiveRecord.new( binding, field_name )
      else
        self::Attribute.new( binding, field_name )
      end
    end

  end
end

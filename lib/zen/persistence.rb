module Zen
  class Persistence

    def self.active_record_column?( klass, field_name )
      Object.const_defined?("ActiveRecord") &&
        ::ActiveRecord.const_defined?("Base") &&
        klass.ancestors.include?( ::ActiveRecord::Base ) &&
        klass.columns.map(&:name).include?( field_name.to_s )
    end

    def self.for( klass, name, field_name )
      if active_record_column?
        ActiveRecord.new( klass, name, field_name )
      else
        Attribute.new( klass, name, field_name )
      end
    end

  end
end

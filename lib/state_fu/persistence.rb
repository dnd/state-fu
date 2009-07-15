module StateFu
  module Persistence
    DEFAULT_FIELD_NAME_SUFFIX = '_field'

    # checks to see if the field_name for persistence is a
    # RelaxDB attribute.
    # Safe to use if RelaxDB is not included.
    def self.relaxdb_document_property?( klass, field_name )
      Object.const_defined?('RelaxDB') &&
        klass.ancestors.include?( ::RelaxDB::Document ) &&
        klass.properties.map(&:to_s).include?( field_name.to_s )
    end

    # checks to see if the field_name for persistence is an
    # ActiveRecord column.
    # Safe to use if ActiveRecord is not included.
    def self.active_record_column?( klass, field_name )
      Object.const_defined?("ActiveRecord") &&
        ::ActiveRecord.const_defined?("Base") &&
        klass.ancestors.include?( ::ActiveRecord::Base ) &&
        klass.table_exists? &&
        klass.columns.map(&:name).include?( field_name.to_s )
    end

    # returns the appropriate persister class for the given class & field name.
    def self.class_for( klass, field_name )
      if active_record_column?( klass, field_name )
        self::ActiveRecord
      elsif relaxdb_document_property?( klass, field_name )
        self::RelaxDB
      else
        self::Attribute
      end
    end

    # returns a persister appropriate to the given binding and field_name
    def self.for( binding, field_name )
      class_for( binding.object.class, field_name ).new( binding, field_name )
    end

    def self.prepare_field( klass, field_name )
      class_for( klass, field_name ).prepare_field( klass, field_name )
    end

  end
end

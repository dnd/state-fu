module StateFu
  module Persistence
    DEFAULT_FIELD_NAME_SUFFIX = '_field'

    def self.prepare_class( klass )
      return if klass.instance_methods.include?( :method_missing_before_state_fu )
      alias_method :method_missing_before_state_fu, :method_missing
      klass.class_eval do
        def method_missing( method_name, *args, &block )
          state_fu!
          args.unshift method_name
          begin
            send( *args, &block )
          rescue NoMethodError => e
            method_missing_before_state_fu( *args, &block )
          end
        end # method_missing
      end # class_eval
    end # prepare_class


    def self.active_record_column?( klass, field_name )
      Object.const_defined?("ActiveRecord") &&
        ::ActiveRecord.const_defined?("Base") &&
        klass.ancestors.include?( ::ActiveRecord::Base ) &&
        klass.columns.map(&:name).include?( field_name.to_s )
    end

    def self.for( binding, field_name )
      if active_record_column?( binding.object.class, field_name )
        self::ActiveRecord.new( binding, field_name )
      else
        self::Attribute.new( binding, field_name )
      end
    end

    def self.prepare_field( klass, field_name )
      if active_record_column?( klass, field_name )
        self::ActiveRecord.prepare_field( klass, field_name )
      else
        self::Attribute.prepare_field( klass, field_name )
      end
    end

  end
end

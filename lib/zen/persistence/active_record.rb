module Zen
  module Persistence
    module ActiveRecord

      def self.included( o )
        o.after_initialize( :set_active_record_before_create! )
      end

      # If peristing via ActiveRecord, ensure our database column
      # defaults to the initial state (DRY).
      #
      # instantiating the Koan will be sufficient to populate the field.
      def set_active_record_before_create!
        return unless active_record_column_name
        _method_name = @method_name.to_sym
        @klass.class_eval { before_create( _method_name ) }
      end

      def active_record?
        @is_active_record ||= Object.const_defined?( 'ActiveRecord' ) &&
          ar_b = Object.const_get( 'ActiveRecord' ).const_get('Base')
        ar_b && klass.ancestors.include?( ar_b )
      end

      def active_record_field?
        @active_record_field ||= active_record? &&
          klass.columns.map(&:name).include?( field_name().to_s )
      end

      def active_record_column_name
        @column_name ||= active_record_field? ? field_name() : nil
      end

    end
  end
end

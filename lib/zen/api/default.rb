module Zen
  module API
    module Default

      module ClassMethods
        def koan( name=Zen::DEFAULT_KOAN, options=Zen::DEFAULT_OPTIONS, &block )
          Zen::Koan.for_class( self, name, options, &block )
        end

        def koans()
          Zen::Space.class_koans[self]
        end

        def koan_names()
          Zen::Space.class_koans[self].keys
        end
      end

      module InstanceMethods
        protected
        def _om
          @_om ||= {}
        end

        public
        def om( name=Zen::DEFAULT_KOAN )
          name = name.to_sym
          if koan = Zen::Space.class_koans[self.class][name]
            _om[name] ||= Zen::Meditation.new( koan, self )
            _om[name]
          end
        end

        def meditations( koan_name = nil )
          if koan_name
            _om[koan_name.to_sym]
          else
            _om
          end
        end
        alias_method :oms, :meditations

        # instantiate all meditations
        # it's useful to call this before_create w/
        # ActiveRecord classes.
        def meditate!( *names )
          if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
            names = self.class.koan_names()
          end
          names.map { |n| om( n ) }
        end

      end
    end
  end
end

module Zen
  module API
    module Default

      module ClassMethods
        def koan( name=Zen::DEFAULT_KOAN, options=Zen::DEFAULT_OPTIONS, &block )
          Zen::Koan.for_class( self, name, options, &block )
        end

        def koans( name=nil )
          Zen::Space.class_koans[self][name && name.to_sym]
        end

        def koan_names()
          koans.keys
        end
      end

      module InstanceMethods

        def _om
          @_om ||= {}
        end

        def om( name=Zen::DEFAULT_KOAN )
          name = name.to_sym
          if binding = Zen::Space.bindings[self.class][name]
            _om[name] ||= Zen::Meditation.new( binding, self )
            _om[name]
          end
        end

        # def bindings
        #   Zen::Space.bindings[self.class]
        # end

        def koans( name = nil )
          self.class.koans( name )
        end


        def meditations( koan_name = nil)
          if koan_name
            _om[koan_name.to_sym]
          else
            _om
          end
        end
        alias_method :oms, :meditations

        def om!( *names )
          if [names || [] ].flatten!.map! {|n| n.to_sym }.empty?
            names = koan_names()
          end
          names.map { |n| om( n ) }
        end

      end
    end
  end
end

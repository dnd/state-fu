module StateFu
  module Applicable
    module InstanceMethods

      # if given a hash of options (or a splatted arglist containing
      # one), merge them into @options. If given a block, eval it
      # (yielding self if the block expects it)

      def apply!( opts={}, &block )
        # opts = opts.extract_options! unless opts.respond_to?(:keys)
        opts.symbolize_keys!
        @options.merge!(opts)
        returning self do
          if block_given?
            case block.arity.abs
            when 1, -1
              instance_exec self, &block
            when 0
              instance_exec &block
            else
              raise ArgumentError, "Your block wants too many arguments!"
            end
          end
        end
      end
    end

    module ClassMethods
    end

    def self.included( mod )
      mod.send( :include, InstanceMethods )
      mod.extend( ClassMethods )
    end
  end
end

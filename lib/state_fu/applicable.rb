module StateFu
  module Applicable
    module InstanceMethods

      # if given a hash of options (or a splatted arglist containing
      # one), merge them into @options. If given a block, eval it
      # (yielding self if the block expects it)

      def apply!( opts={}, &block )
        opts = opts.extract_options! unless opts.respond_to?(:keys)
        opts.symbolize_keys!
        return self unless block_given?
        case block.arity.abs
        when 1, -1
          instance_exec self, &block
        when 0
          instance_eval &block
        else
          raise ArgumentError, "block wants too many arguments!"
        end
        self
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

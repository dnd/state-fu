module StateFu    
  module Applicable
    module InstanceMethods
      
      # if given a hash of options (or a splatted arglist containing
      # one), merge them into @options. If given a block, eval it
      # (yielding self if the block expects it)
      
      def apply!( options={}, &block )
        options.respond_to?(:keys) || options = options.extract_options!
        @options.merge!( options.symbolize_keys! )
        return self unless block_given?
        case block.arity
        when 1     # lambda{ |state| ... }
          yield self
        when -1, 0 # lambda{ } ( -1 in ruby 1.8.x but 0 in 1.9.x )
          instance_eval &block
        else
          raise ArgumentError, "unexpected block arity: #{block.arity}"
        end
        self
      end
      alias_method :update!, :apply!
    end
    
    module ClassMethods
    end

    def self.included( mod )
      mod.send( :include, InstanceMethods )
      mod.extend( ClassMethods )
    end
  end
end

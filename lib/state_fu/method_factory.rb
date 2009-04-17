module StateFu
  class MethodFactory
    attr_reader :target

    def initialize( klass )
      @target = klass
      raise ArgumentError unless target.is_a?( Class )
    end

  end
end

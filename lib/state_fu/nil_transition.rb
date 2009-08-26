module StateFu
  
  class NilTransition
    def method_missing(method_name, *args, &block)
      nil
    end
    
    def blank?
      true
    end
    
    def nil?
      true
    end

    # def <=> x
    #   false <=> x
    # end
    #    
    # def | x
    #   false
    # end
    # 
    # def & x
    #   false
    # end
    # 
    # def ^ x
    #   false
    # end
    #
    # def equal? x
    #   x.is_a? NilTransition || x == nil
    # end

    def == x
      case x
      when false
        true
      when true
        false
      else
        nil
      end
    end
    
  end
  
end
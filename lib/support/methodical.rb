module StateFu
  module Methodical

    def self.__define_method( method_name, &block )
      self.class.class_eval do
        define_method method_name, &block
      end
    end

    def __define_singleton_method( method_name, &block )
      (class << object; self; end).class_eval do
        define_method method_name, &block
      end
    end

  end
end

class Object
  def extended_by #:nodoc:
    ancestors = class << self; ancestors end
    ancestors.select { |mod| mod.class == Module } - [ Object, Kernel ]
  end
end

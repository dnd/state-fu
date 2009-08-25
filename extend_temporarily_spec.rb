#!/usr/bin/env ruby

class Object

  # within the block, handle method_missing with another object.
  def with_methods_on( other )
    _other = other
    # todo: also handle respond_to?
    (class << self; self; end).class_eval do
      alias_method :method_missing_before_voodoo, :method_missing
      define_method :method_missing do |method_name, *args|
        if _other.respond_to?( method_name )
          _other.send( method_name, *args )
        else
          method_missing_before_voodoo( method_name, *args )
        end
      end
    end

    result = yield

    (class << self; self; end).class_eval do
      alias_method :method_missing, :method_missing_before_voodoo
      undef_method :method_missing_before_voodoo
    end
    result
  end

end

class MyObject
  def existing_method *args; self; end
  def conflicting_method *args; self; end
end

class OtherObject
  def new_method *args; self; end
  def conflicting_method *args; self; end
end

describe "extending an object temporarily with Object#with_methods_on(other)" do

  before do
    @m = MyObject.new
    @o = OtherObject.new
  end

  it "existing methods behave normally" do
    @m.with_methods_on(@o) { @m.existing_method.should == @m }
  end

  it "should have access to the other object's methods inside the block" do
    @m.with_methods_on( @o ) { @m.new_method.should == @o }
  end

  it "should return the value of the block" do
    @m.with_methods_on( @o ) { 42 }.should == 42
  end

  it "should use the existing method if both objects have a given method" do
    @m.with_methods_on( @o ) { @m.conflicting_method.should == @m }
  end

  describe "when method_missing is defined" do

    before do
      (class << @m; self; end).class_eval do
        define_method :method_missing do |method_name, *args|
          return [:method_missing, method_name.to_sym, *args]
        end
      end
    end

    it "should still work" do
      @m.with_methods_on( @o ) { @m.new_method.should == @o }
    end

    it "should not alter the original implementation of method_missing" do
      original_result = @m.unknown_method
      @m.with_methods_on( @o ) { @m.unknown_method.should == original_result }
      @m.unknown_method.should == original_result
    end
  end
end

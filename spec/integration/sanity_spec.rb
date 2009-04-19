require File.expand_path("#{File.dirname(__FILE__)}/../helper")

class Moo
  def arity_1( a )
    raise "!"
  end

  def arity_0( )
    raise "!"
  end
end

describe "sanity check: rr / arity" do
  it "should have the expected arity for standard methods" do
    m = Moo.new()
    m.method(:arity_1).arity.should == 1
    m.method(:arity_0).arity.should == 0
  end

  it "should have the expected arity when methods are mocked" do
    m = Moo.new()
    a1 = Object.new
    a0 = Object.new
    stub( a1 ).arity() { 1 }
    stub( a0 ).arity() { 0 }
    stub( m ).method(:arity_1) { a1 }
    stub( m ).method(:arity_0) { a0 }
    m.method(:arity_1).arity.should == 1
    m.method(:arity_0).arity.should == 0
  end
end

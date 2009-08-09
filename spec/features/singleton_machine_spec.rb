require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "singleton machines" do
  before do
    make_pristine_class('Klass')
    @m = StateFu::Machine.new
    @obj = Klass.new
    @m.bind!( @obj, :binding_name)
  end

  it "should return a binding to the machine when calling the binding's name" do
    @obj.should respond_to(:binding_name)
    @obj.binding_name.should be_kind_of(StateFu::Binding)
    @obj.binding_name.machine.should == @m
    @obj.binding_name.object.should == @obj
  end


end

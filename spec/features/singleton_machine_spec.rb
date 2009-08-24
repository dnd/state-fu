require File.expand_path("#{File.dirname(__FILE__)}/../helper")


describe "singleton machines" do
  before do
    make_pristine_class('Klass')
    @m = StateFu::Machine.new do
      state :a do
        event :beatify, :transitions_to => :b
      end
    end
    @m.events.length.should == 1
    @obj = Klass.new
    @m.bind!( @obj, :my_binding)
  end

  it "should return a binding to the machine when calling the binding's name" do
    @obj.should respond_to(:my_binding)
    @obj.my_binding.should be_kind_of(StateFu::Binding)
    @obj.my_binding.machine.should == @m
    @obj.my_binding.object.should == @obj
  end

  it "should have event methods defined" do
    %w/beatify can_beatify? beatify!/.each do |method_name|
      @obj.my_binding.should respond_to(method_name)
      @obj.should respond_to(method_name)
    end
  end

  it "should transition" do
    @b = @obj.my_binding
    @b.current_state.should == :a
    t = @obj.beatify!
    t.should be_kind_of(StateFu::Transition)
    t.should be_accepted
    @b.current_state.should == :b
  end

end

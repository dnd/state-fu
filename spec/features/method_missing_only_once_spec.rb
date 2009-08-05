require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "method_missing" do
  include MySpecHelper
  before do
    make_pristine_class('Klass')
    Klass.state_fu_machine() {}
    @obj = Klass.new
  end

  it "should revert to the original method_missing after it is called once" do
    mock.proxy( @obj ).state_fu!.times(1)
    mm1 = @obj.method(:method_missing)
    call_snafu = lambda do
      begin
        @obj.snafu!
      rescue NoMethodError
      end
    end
    call_snafu.call()
    mm2 = @obj.method(:method_missing)
    mm1.should_not == mm2
    call_snafu.call()
    mm3 = @obj.method(:method_missing)
    mm3.should == mm2
    # @obj.snafu
  end
end

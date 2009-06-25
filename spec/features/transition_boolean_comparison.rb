require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "extending bindings and transitions with Lathe#helper" do

  include MySpecHelper

  before(:each) do
    reset!
    make_pristine_class('Klass')
    Klass.class_eval do
      attr_accessor :ok
    end

    @machine = Klass.machine do
      chain "a -a2b-> b -b2c-> c"
      events.each do |e|
        e.requires :ok
      end
    end

    @obj = Klass.new
    @binding       = @obj.state_fu
    @transition    = @obj.state_fu.transition(:a2b)
  end # before

  #
  #

  describe StateFu::Transition  do
    describe "#==" do

      describe "with an unaccepted transition" do
        before do
          stub(@transition).accepted? { false }
        end

        it "should == true" do
          @transition.should_not == true
        end

        it "should not == false" do
          @transition.should == false
        end

        it "should === true" do
          @transition.should_not === true
        end

        it "should not === false" do
          @transition.should === false
        end

        it "should not evaluate as truthy" do
          pending
          x = @transition || 1
          x.should == 1
        end
      end


      describe "with an accepted transition" do
        before do
          stub(@transition).accepted? { true }
        end
        it "should == true" do
          @transition.should == true
        end

        it "should not == false" do
          @transition.should_not == false
        end

        it "should === true" do
          @transition.should === true
        end

        it "should not === false" do
          @transition.should_not === false
        end

        it "should evaluate as truthy" do
          x = @transition || 1
          x.should == @transition
        end

      end
    end

  end
end

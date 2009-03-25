require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::FuSpace.reset!

##
##
##

describe "An instance of Klass with StateFu included:" do
  include MySpecHelper
  before(:each) do
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  it "should return nil given .om()" do
    @k.om().should be_nil
  end

  it "should return {} given .bindings()" do
    @k.bindings().should == {}
  end

  it "should return [] given .meditate!()" do
    @k.meditate!.should == []
  end

  describe "Having called Klass.machine() with an empty block:" do
    before(:each) do
      Klass.machine do
      end
      StateFu::DEFAULT_MACHINE.should == :om
    end

    it "should return a StateFu::Binding given .om()" do
      @k.om().should be_kind_of( StateFu::Binding )
    end

    describe "before .om() or .meditate!" do
      it "should return {} given .bindings()" do
        @k.bindings().should == {}
      end
    end

    describe "after .om()" do
      it "should return { :om => <StateFu::Binding>} given .bindings()" do
        @k.om()
        @k.bindings().length.should == 1
        @k.bindings().keys.should == [:om]
        @k.bindings().values.first.should be_kind_of( StateFu::Binding )
      end
    end

    describe "after .meditate!()" do
      it "should return { :om => <StateFu::Binding>} given .bindings()" do
        @k.meditate!()
        @k.bindings().length.should == 1
        @k.bindings().keys.should == [:om]
        @k.bindings().values.first.should be_kind_of( StateFu::Binding )
      end
    end

    it "should return [<StateFu::Binding>] given .meditate!()" do
      @k.meditate!.length.should == 1
    end

    describe "Having called Klass.machine(:two) with an empty block:" do
      before(:each) do
        Klass.machine(:two) do
        end
      end

      it "should return the same Binding given .om() and .om(:om)" do
        @k.binding().should be_kind_of( StateFu::Binding )
        @k.binding().should == @k.om(:om)
      end

      it "should return a StateFu::Binding given .om(:two)" do
        @k.om(:two).should be_kind_of( StateFu::Binding )
        @k.om(:two).should_not == @k.om(:om)
      end

      it "should return nil given .om(:hibiscus)" do
        @k.om(:hibiscus).should be_nil
      end

      it "should return [<StateFu::Binding>,<StateFu::Binding>] given .meditate!" do
        @k.meditate!.should be_kind_of( Array )
        @k.meditate!.length.should == 2
        @k.meditate!.each { |m| m.should be_kind_of( StateFu::Binding ) }
      end
    end
  end
end

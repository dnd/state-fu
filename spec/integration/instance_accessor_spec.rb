require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::Space.reset!

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

  it "should return {} given .meditations()" do
    @k.meditations().should == {}
  end

  it "should return [] given .meditate!()" do
    @k.meditate!.should == []
  end

  describe "Having called Klass.machine() with an empty block:" do
    before(:each) do
      Klass.machine do
      end
      StateFu::DEFAULT_KOAN.should == :om
    end

    it "should return a StateFu::Meditation given .om()" do
      @k.om().should be_kind_of( StateFu::Meditation )
    end

    describe "before .om() or .meditate!" do
      it "should return {} given .meditations()" do
        @k.meditations().should == {}
      end
    end

    describe "after .om()" do
      it "should return { :om => <StateFu::Meditation>} given .meditations()" do
        @k.om()
        @k.meditations().length.should == 1
        @k.meditations().keys.should == [:om]
        @k.meditations().values.first.should be_kind_of( StateFu::Meditation )
      end
    end

    describe "after .meditate!()" do
      it "should return { :om => <StateFu::Meditation>} given .meditations()" do
        @k.meditate!()
        @k.meditations().length.should == 1
        @k.meditations().keys.should == [:om]
        @k.meditations().values.first.should be_kind_of( StateFu::Meditation )
      end
    end

    it "should return [<StateFu::Meditation>] given .meditate!()" do
      @k.meditate!.length.should == 1
    end

    describe "Having called Klass.machine(:two) with an empty block:" do
      before(:each) do
        Klass.machine(:two) do
        end
      end

      it "should return the same Meditation given .om() and .om(:om)" do
        @k.om().should be_kind_of( StateFu::Meditation )
        @k.om().should == @k.om(:om)
      end

      it "should return a StateFu::Meditation given .om(:two)" do
        @k.om(:two).should be_kind_of( StateFu::Meditation )
        @k.om(:two).should_not == @k.om(:om)
      end

      it "should return nil given .om(:hibiscus)" do
        @k.om(:hibiscus).should be_nil
      end

      it "should return [<StateFu::Meditation>,<StateFu::Meditation>] given .meditate!" do
        @k.meditate!.should be_kind_of( Array )
        @k.meditate!.length.should == 2
        @k.meditate!.each { |m| m.should be_kind_of( StateFu::Meditation ) }
      end
    end
  end
end

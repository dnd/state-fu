require File.expand_path("#{File.dirname(__FILE__)}/../helper")

Zen::Space.reset!

##
##
##

describe "An instance of Klass with Zen included:" do
  before(:each) do
    c_name = "Klass"
    # this is just for paranoia:
    Object.send(:remove_const, c_name ) if Object.const_defined?( c_name )
    Zen::Space.reset!
    class Klass
      include Zen
    end
    @i = Klass.new
  end

  it "should return nil given .om()" do
    @i.om().should be_nil
  end

  it "should return {} given .meditations()" do
    @i.meditations().should == {}
  end

  it "should return [] given .meditate!()" do
    @i.meditate!.should == []
  end

  describe "Having called Klass.koan() with an empty block:" do
    before(:each) do
      Klass.koan do
      end
      Zen::DEFAULT_KOAN.should == :om
    end

    it "should return a Zen::Meditation given .om()" do
      @i.om().should be_kind_of( Zen::Meditation )
    end

    describe "before .om() or .meditate!" do
      it "should return {} given .meditations()" do
        @i.meditations().should == {}
      end
    end

    describe "after .om()" do
      it "should return { :om => <Zen::Meditation>} given .meditations()" do
        @i.om()
        @i.meditations().length.should == 1
        @i.meditations().keys.should == [:om]
        @i.meditations().values.first.should be_kind_of( Zen::Meditation )
      end
    end

    describe "after .meditate!()" do
      it "should return { :om => <Zen::Meditation>} given .meditations()" do
        @i.meditate!()
        @i.meditations().length.should == 1
        @i.meditations().keys.should == [:om]
        @i.meditations().values.first.should be_kind_of( Zen::Meditation )
      end
    end

    it "should return [<Zen::Meditation>] given .meditate!()" do
      @i.meditate!.length.should == 1
    end

    describe "Having called Klass.koan(:two) with an empty block:" do
      before(:each) do
        Klass.koan(:two) do
        end
      end

      it "should return the same Meditation given .om() and .om(:om)" do
        @i.om().should be_kind_of( Zen::Meditation )
        @i.om().should == @i.om(:om)
      end

      it "should return a Zen::Meditation given .om(:two)" do
        @i.om(:two).should be_kind_of( Zen::Meditation )
        @i.om(:two).should_not == @i.om(:om)
      end

      it "should return nil given .om(:hibiscus)" do
        @i.om(:hibiscus).should be_nil
      end

      it "should return [<Zen::Meditation>,<Zen::Meditation>] given .meditate!" do
        @i.meditate!.should be_kind_of( Array )
        @i.meditate!.length.should == 2
        @i.meditate!.each { |m| m.should be_kind_of( Zen::Meditation ) }
      end
    end
  end
end

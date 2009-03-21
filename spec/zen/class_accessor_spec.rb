require File.expand_path("#{File.dirname(__FILE__)}/../helper")

Zen::Space.reset!

##
##
##

describe "A pristine class Klass with Zen included:" do
  before(:each) do
    c_name = "Klass"
    # this is just for paranoia:
    Object.send(:remove_const, c_name ) if Object.const_defined?( c_name )
    Zen::Space.reset!
    class Klass
      include Zen
    end
  end

  it "should return nil given Klass.koan()" do
    Klass.should respond_to(:koan)
    Klass.koan.should be_nil
  end

  it "should return {} given Klass.koans()" do
    Klass.should respond_to(:koans)
    Klass.koans.should == {}
  end

  it "should return [] given Klass.koan_names()" do
    Klass.should respond_to(:koan_names)
    Klass.koan_names.should == []
  end

  ##
  ##
  ##

  describe "Having called Klass.koan() with an empty block:" do
    before(:each) do
      Klass.koan do
      end
      Zen::DEFAULT_KOAN.should == :om
    end

    it "should return a Zen::Koan given Klass.koan()" do
      Klass.should respond_to(:koan)
      Klass.koan.should_not be_nil
      Klass.koan.should be_kind_of( Zen::Koan )
    end

    it "should return { :om => <Zen::Koan> } given Klass.koans()" do
      Klass.should respond_to(:koans)
      koans = Klass.koans()
      koans.should be_kind_of(Hash)
      koans.should_not be_empty
      koans.length.should == 1
      koans.keys.should == [:om]
      koans.values.first.should be_kind_of( Zen::Koan )
    end

    it "should returns [:om] given Klass.koan_names()" do
      Klass.should respond_to(:koan_names)
      Klass.koan_names.should == [:om]
    end

    describe "Having called Klass.koan(:two) with an empty block:" do
      before(:each) do
        Klass.koan(:two) do
        end
      end

      it "should return a Zen::Koan given Klass.koan(:two)" do
        Klass.should respond_to(:koan)
        Klass.koan(:two).should_not be_nil
        Klass.koan(:two).should be_kind_of( Zen::Koan )
      end

      it "should return nil given Klass.koan(:three)" do
        Klass.should respond_to(:koan)
        Klass.koan(:three).should be_nil
      end

      it "should return { :om => <Zen::Koan>, :two => <Zen::Koan> } given Klass.koans()" do
        Klass.should respond_to(:koans)
        koans = Klass.koans()
        koans.should be_kind_of(Hash)
        koans.should_not be_empty
        koans.length.should == 2
        koans.keys.should include :om
        koans.keys.should include :two
        koans.values.length.should == 2
        koans.values.each { |v| v.should be_kind_of( Zen::Koan ) }
      end

      it "should return [:om, :two] give Klass.koan_names (unordered)" do
        Klass.should respond_to(:koan_names)
        Klass.koan_names.length.should == 2
        Klass.koan_names.should include :om
        Klass.koan_names.should include :two
      end
    end

    describe "An empty class Child which inherits from Klass" do
      before() do
        Object.send(:remove_const, 'Child' ) if Object.const_defined?( 'Child' )
        class Child < Klass
        end
      end

      it "does NOT inherit it's parent class' Koan !!" do
        Child.koan.should be_nil
      end

      it "should know the Koan after calling Klass.koan.teach!( Child )" do
        Child.koan.should be_nil
        Klass.koan.teach!( Child )
        Child.koan.should_not be_nil
        Child.koan.should == Klass.koan
      end

    end

  end
end

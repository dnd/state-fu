require File.expand_path("#{File.dirname(__FILE__)}/../helper")

Zen::Space.reset!

##
##
##
describe Zen::Space do
  include MySpecHelper

  before(:each) do
    reset!
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  describe "Before any Koan is defined" do
    it "should return {} given Zen::Space.class_koans()" do
      Zen::Space.should respond_to(:class_koans)
      Zen::Space.class_koans.should == {}
    end
  end

  describe "Having called Klass.koan() with an empty block:" do
    before(:each) do
      Klass.koan do
      end
      Zen::DEFAULT_KOAN.should == :om
    end

    it "should return { Klass => { ... } } given Zen::Space.class_koans()" do
      Zen::Space.should respond_to(:class_koans)
      koans = Zen::Space.class_koans()
      koans.keys.should == [Klass]
      koans.values.first.should be_kind_of( Hash )
    end

    it "should return { :om => <Zen::Koan> } given Zen::Space.class_koans[Klass]" do
      Zen::Space.should respond_to(:class_koans)
      koans = Zen::Space.class_koans[Klass]
      koans.should be_kind_of(Hash)
      koans.should_not be_empty
      koans.length.should == 1
      koans.keys.should == [:om]
      koans.values.first.should be_kind_of( Zen::Koan )
    end

    it "should return { Klass => { ... } } given Zen::Space.field_names()" do
      Zen::Space.should respond_to(:field_names)
      fields = Zen::Space.field_names()
      fields.keys.should == [Klass]
      fields.values.first.should be_kind_of( Hash )
    end

    it "should return { :om => :om_state } given Zen::Space.field_names[Klass]" do
      Zen::Space.should respond_to(:field_names)
      fields = Zen::Space.field_names[Klass]
      fields.should be_kind_of(Hash)
      fields.should_not be_empty
      fields.length.should == 1
      fields.keys.should == [:om]
      fields.values.should == [:om_state]
    end

    describe "Having called Klass.koan(:two) with an empty block:" do
      before(:each) do
        # Klass.koan.should_not be_nil
        Klass.koan(:two) do
        end
      end

      it "should return { :om => <Zen::Koan>, :two => <Zen::Koan> } given Zen::Space.class_koans()" do
        Zen::Space.should respond_to(:class_koans)
        koans = Zen::Space.class_koans[Klass]
        koans.should be_kind_of(Hash)
        koans.should_not be_empty
        koans.length.should == 2
        koans.keys.should include :om
        koans.keys.should include :two
        koans.values.length.should == 2
        koans.values.each { |v| v.should be_kind_of( Zen::Koan ) }
      end

      describe "Having called Zen::Space.reset!" do
        before(:each) do
          Zen::Space.reset!
        end
        it "should return {} given Zen::Space.class_koans()" do
          Zen::Space.should respond_to(:class_koans)
          Zen::Space.class_koans.should == {}
        end
      end

    end
  end
end


require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::Space.reset!

##
##
##
describe StateFu::Space do
  include MySpecHelper

  before(:each) do
    reset!
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  describe "Before any Koan is defined" do
    it "should return {} given StateFu::Space.class_koans()" do
      StateFu::Space.should respond_to(:class_koans)
      StateFu::Space.class_koans.should == {}
    end
  end

  describe "Having called Klass.koan() with an empty block:" do
    before(:each) do
      Klass.koan do
      end
      StateFu::DEFAULT_KOAN.should == :om
    end

    it "should return { Klass => { ... } } given StateFu::Space.class_koans()" do
      StateFu::Space.should respond_to(:class_koans)
      koans = StateFu::Space.class_koans()
      koans.keys.should == [Klass]
      koans.values.first.should be_kind_of( Hash )
    end

    it "should return { :om => <StateFu::Koan> } given StateFu::Space.class_koans[Klass]" do
      StateFu::Space.should respond_to(:class_koans)
      koans = StateFu::Space.class_koans[Klass]
      koans.should be_kind_of(Hash)
      koans.should_not be_empty
      koans.length.should == 1
      koans.keys.should == [:om]
      koans.values.first.should be_kind_of( StateFu::Koan )
    end

    it "should return { Klass => { ... } } given StateFu::Space.field_names()" do
      StateFu::Space.should respond_to(:field_names)
      fields = StateFu::Space.field_names()
      fields.keys.should == [Klass]
      fields.values.first.should be_kind_of( Hash )
    end

    it "should return { :om => :om_state } given StateFu::Space.field_names[Klass]" do
      StateFu::Space.should respond_to(:field_names)
      fields = StateFu::Space.field_names[Klass]
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

      it "should return { :om => <StateFu::Koan>, :two => <StateFu::Koan> } given StateFu::Space.class_koans()" do
        StateFu::Space.should respond_to(:class_koans)
        koans = StateFu::Space.class_koans[Klass]
        koans.should be_kind_of(Hash)
        koans.should_not be_empty
        koans.length.should == 2
        koans.keys.sort.should == [:om, :two]
        koans.values.each { |v| v.should be_kind_of( StateFu::Koan ) }
      end

      describe "Having called StateFu::Space.reset!" do
        before(:each) do
          StateFu::Space.reset!
        end
        it "should return {} given StateFu::Space.class_koans()" do
          StateFu::Space.should respond_to(:class_koans)
          StateFu::Space.class_koans.should == {}
        end
      end

    end
  end
end


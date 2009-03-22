require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding events to a Koan" do

  include MySpecHelper

  before(:each) do
    make_pristine_class 'Klass'
    @k = Klass.new()
  end


  describe "When there is an empty koan" do
    before do
      Klass.koan() { }
    end

    describe "calling Klass.koan().events" do
      it "should return []" do
        Klass.koan().events.should == []
      end
    end

    describe "calling event() in a Klass.koan() block" do

      it "should require a name for the event" do
        -> { Klass.koan(){ event {} } }.should raise_error(ArgumentError)
      end

      it "should create 2 states given koan.event() { from :dead, :to => :alive } " do
        Klass.koan do
          event :die do
            from :dead, :to => :alive
          end
        end
        Klass.koan.state_names.should == [:dead, :alive]
      end

      it "should create 2 states given koan.event() { |s| s.from :dead, :to => :alive } " do
        Klass.koan do
          event :die do |s|
            s.from :dead, :to => :alive
          end
        end
        Klass.koan.state_names.should == [:dead, :alive]
      end

    end
  end

end


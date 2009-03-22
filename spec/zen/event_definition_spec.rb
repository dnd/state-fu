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

      it "should create the states mentioned in .from() in the .event() block" do
        Klass.koan do
          event :die do
            self.from :dead, :to => :alive
          end
        end
        Klass.koan.state_names.should == [:dead, :alive]
      end

    end
  end

end


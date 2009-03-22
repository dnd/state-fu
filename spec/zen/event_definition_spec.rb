require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding events to a Koan outside a state block" do

  include MySpecHelper

  describe "When there is an empty koan" do
    before do
      reset!
      make_pristine_class 'Klass'
      Klass.koan() { }
    end

    describe "calling Klass.koan().events" do
      it "should return []" do
        Klass.koan().events.should == []
      end
    end

    describe "calling event(){ from :dead, :to => :alive } in a Klass.koan()" do
      before do
        Klass.koan do
          event :die do # arity == 0
            from :dead, :to => :alive
          end
        end
      end

      it "should require a name when calling koan.event()" do
        -> { Klass.koan(){ event {} } }.should raise_error(ArgumentError)
      end

      it "should add 2 states to the koan called [:dead, :alive] " do
        Klass.koan.state_names.should == [:dead, :alive]
        Klass.koan.states.length.should == 2
        Klass.koan.states.each { |s| s.should be_kind_of(Zen::State) }
      end
    end

    # arity of blocks is optional, thanks to magic fairy dust ;)
    describe "calling event(){ |s| s.from :dead, :to => :alive } in a Klass.koan()" do
      before do
        Klass.koan do
          event :die do |s|
            s.from :dead, :to => :alive
          end
        end
      end

      it "should add 2 states to the koan called [:dead, :alive] " do
        Klass.koan.state_names.should == [:dead, :alive]
        Klass.koan.states.length.should == 2
        Klass.koan.states.each { |s| s.should be_kind_of(Zen::State) }
      end
    end

  end
end


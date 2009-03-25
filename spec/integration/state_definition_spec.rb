require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding states to a Koan" do

  include MySpecHelper

  before(:each) do
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  it "should allow me to call koan() { state(:egg) }" do
    lambda {Klass.koan(){ state :egg } }.should_not raise_error()
  end

  describe "having called koan() { state(:egg) }" do

    before(:each) do
      Klass.koan(){ state :egg }
    end

    it "should return [:egg] given koan.state_names" do
      Klass.koan.should respond_to(:state_names)
      Klass.koan.state_names.should == [:egg]
    end

    it "should return [<StateFu::State @name=:egg>] given koan.states" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should be_kind_of( StateFu::State )
      Klass.koan.states.first.name.should == :egg
    end

    it "should return :egg given koan.states.first.name" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should respond_to(:name)
      Klass.koan.states.first.name.should == :egg
    end

    it "should return a <StateFu::State @name=:egg> given koan.states[:egg]" do
      Klass.koan.should respond_to(:states)
      result = Klass.koan.states[:egg]
      result.should_not be_nil
      result.should be_kind_of( StateFu::State )
      result.name.should == :egg
    end


    it "should allow me to call koan(){ state(:chick) }" do
      lambda {Klass.koan(){ state :chick } }.should_not raise_error()
    end

    describe "having called koan() { state(:chick) }" do
      before do
        Klass.koan() { state :chick }
      end

      it "should return [:egg] given koan.state_names" do
        Klass.koan.should respond_to(:state_names)
        Klass.koan.state_names.should == [:egg, :chick]
      end

      it "should return a <StateFu::State @name=:chick> given koan.states[:egg]" do
        Klass.koan.should respond_to(:states)
        result = Klass.koan.states[:chick]
        result.should_not be_nil
        result.should be_kind_of( StateFu::State )
        result.name.should == :chick
      end

    end

    describe "calling koan() { state(:bird) {|s| .. } }" do

      it "should yield the state to the block as |s|" do
        reader = nil
        Klass.koan() do
          state(:bird) do |s|
            reader = s
          end
        end
        reader.should be_kind_of( StateFu::Reader )
        reader.phrase.should be_kind_of( StateFu::State )
        reader.phrase.name.should == :bird
      end

    end

    describe "calling koan() { state(:bird) {  .. } }" do

      it "should instance_eval the block as a StateFu::Reader" do
        reader = nil
        Klass.koan() do
          state(:bird) do
            reader = self
          end
        end
        reader.should be_kind_of(StateFu::Reader)
        reader.phrase.should be_kind_of(StateFu::State)
        reader.phrase.name.should == :bird
      end

    end

    describe "calling state(:bird) consecutive times" do

      it "should yield the same state each time" do
        Klass.koan() { state :bird }
        bird_1 = Klass.koan.states[:bird]
        Klass.koan() { state :bird }
        bird_2 = Klass.koan.states[:bird]
        bird_1.should == bird_2
      end

    end
  end

  describe "calling koan() { states(:egg, :chick, :bird, :poultry => true) }" do

    it "should create 3 states" do
      Klass.koan().should be_empty
      Klass.koan() { states(:egg, :chick, :bird, :poultry => true) }
      Klass.koan().state_names().should == [:egg, :chick, :bird]
      Klass.koan().states.length.should == 3
      Klass.koan().states.map(&:name).should == [:egg, :chick, :bird]
      Klass.koan().states().each do |s|
        s.options[:poultry].should be_true
        s.should be_kind_of(StateFu::State)
      end

      describe "merging options" do
        it "should merge options when states are mentioned more than once" do
          StateFu::Space.reset!
          Klass.koan() { states(:egg, :chick, :bird, :poultry => true) }
          koan = Klass.koan
          koan.states.length.should == 3

          # make sure they're the same states
          states_1 = koan.states
          Klass.koan(){ states( :egg, :chick, :bird, :covering => 'feathers')}
          states_1.should == koan.states

          # ensure options were merged
          koan.states().each do |s|
            s.options[:poultry].should be_true
            s.options[:covering].should == 'feathers'
            s.should be_kind_of(StateFu::State)
          end
        end
      end
    end
  end

  describe "adding events inside a state block" do
    before do
      @lambda = lambda{ Klass.koan(){ state(:egg){ event(:hatch, :to => :chick) }}}
    end

    it "should not throw an error" do
      @lambda.should_not raise_error
    end

    describe "Klass.koan(){ state(:egg){ event(:hatch, :to => :chick) }}}" do
      before() do
        Klass.koan(){ state(:egg){ event(:hatch, :to => :chick) }}
      end
      it "should add an event :hatch to the koan" do
      end
    end
  end

end


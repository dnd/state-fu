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
    -> {Klass.koan(){ state :egg } }.should_not raise_error()
  end

  describe "having called koan() { state(:egg) }" do

    before(:each) do
      Klass.koan(){ state :egg }
    end

    it "should return [:egg] given koan.state_names" do
      Klass.koan.should respond_to(:state_names)
      Klass.koan.state_names.should == [:egg]
    end

    it "should return [<Zen::State @name=:egg>] given koan.states" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should be_kind_of( Zen::State )
      Klass.koan.states.first.name.should == :egg
    end

    it "should return :egg given koan.states.first.name" do
      Klass.koan.should respond_to(:states)
      Klass.koan.states.length.should == 1
      Klass.koan.states.first.should respond_to(:name)
      Klass.koan.states.first.name.should == :egg
    end

    it "should return a <Zen::State @name=:egg> given koan.states[:egg]" do
      Klass.koan.should respond_to(:states)
      result = Klass.koan.states[:egg]
      result.should_not be_nil
      result.should be_kind_of( Zen::State )
      result.name.should == :egg
    end


    it "should allow me to call koan(){ state(:chick) }" do
      -> {Klass.koan(){ state :chick } }.should_not raise_error()
    end

    describe "having called koan() { state(:chick) }" do
      before do
        Klass.koan() { state :chick }
      end

      it "should return [:egg] given koan.state_names" do
        Klass.koan.should respond_to(:state_names)
        Klass.koan.state_names.should == [:egg, :chick]
      end

      it "should return a <Zen::State @name=:chick> given koan.states[:egg]" do
        Klass.koan.should respond_to(:states)
        result = Klass.koan.states[:chick]
        result.should_not be_nil
        result.should be_kind_of( Zen::State )
        result.name.should == :chick
      end

    end

    describe "calling koan() { state(:bird) {|s| .. } }" do

      it "should yield the state to the block as |s|" do
        _state = nil
        Klass.koan() do
          state(:bird) do |s|
            _state = s
          end
        end
        _state.should be_kind_of(Zen::State)
        _state.name.should == :bird
      end

    end

    describe "calling koan() { state(:bird) {  .. } }" do

      it "should instance_eval the block as the state" do
        _state = nil
        Klass.koan() do
          state(:bird) do
            _state = self
          end
        end
        _state.should be_kind_of(Zen::State)
        _state.name.should == :bird
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

  describe "calling state(:egg, :chick, :bird) in the koan block" do

    it "should create 3 states" do
      Klass.koan().should be_nil
      Klass.koan() { state :egg, :chick, :bird }
      Klass.koan().state_names().should == [:egg, :chick, :bird]
      Klass.koan().states().each do |s|
        s.should be_kind_of(Zen::State)
      end
    end

  end

end

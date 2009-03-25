require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding states to a Machine" do

  include MySpecHelper

  before(:each) do
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  it "should allow me to call machine() { state(:egg) }" do
    lambda {Klass.machine(){ state :egg } }.should_not raise_error()
  end

  describe "having called machine() { state(:egg) }" do

    before(:each) do
      Klass.machine(){ state :egg }
    end

    it "should return [:egg] given machine.state_names" do
      Klass.machine.should respond_to(:state_names)
      Klass.machine.state_names.should == [:egg]
    end

    it "should return [<StateFu::State @name=:egg>] given machine.states" do
      Klass.machine.should respond_to(:states)
      Klass.machine.states.length.should == 1
      Klass.machine.states.first.should be_kind_of( StateFu::State )
      Klass.machine.states.first.name.should == :egg
    end

    it "should return :egg given machine.states.first.name" do
      Klass.machine.should respond_to(:states)
      Klass.machine.states.length.should == 1
      Klass.machine.states.first.should respond_to(:name)
      Klass.machine.states.first.name.should == :egg
    end

    it "should return a <StateFu::State @name=:egg> given machine.states[:egg]" do
      Klass.machine.should respond_to(:states)
      result = Klass.machine.states[:egg]
      result.should_not be_nil
      result.should be_kind_of( StateFu::State )
      result.name.should == :egg
    end


    it "should allow me to call machine(){ state(:chick) }" do
      lambda {Klass.machine(){ state :chick } }.should_not raise_error()
    end

    describe "having called machine() { state(:chick) }" do
      before do
        Klass.machine() { state :chick }
      end

      it "should return [:egg] given machine.state_names" do
        Klass.machine.should respond_to(:state_names)
        Klass.machine.state_names.should == [:egg, :chick]
      end

      it "should return a <StateFu::State @name=:chick> given machine.states[:egg]" do
        Klass.machine.should respond_to(:states)
        result = Klass.machine.states[:chick]
        result.should_not be_nil
        result.should be_kind_of( StateFu::State )
        result.name.should == :chick
      end

    end

    describe "calling machine() { state(:bird) {|s| .. } }" do

      it "should yield the state to the block as |s|" do
        reader = nil
        Klass.machine() do
          state(:bird) do |s|
            reader = s
          end
        end
        reader.should be_kind_of( StateFu::Reader )
        reader.phrase.should be_kind_of( StateFu::State )
        reader.phrase.name.should == :bird
      end

    end

    describe "calling machine() { state(:bird) {  .. } }" do

      it "should instance_eval the block as a StateFu::Reader" do
        reader = nil
        Klass.machine() do
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
        Klass.machine() { state :bird }
        bird_1 = Klass.machine.states[:bird]
        Klass.machine() { state :bird }
        bird_2 = Klass.machine.states[:bird]
        bird_1.should == bird_2
      end

    end
  end

  describe "calling machine() { states(:egg, :chick, :bird, :poultry => true) }" do

    it "should create 3 states" do
      Klass.machine().should be_empty
      Klass.machine() { states(:egg, :chick, :bird, :poultry => true) }
      Klass.machine().state_names().should == [:egg, :chick, :bird]
      Klass.machine().states.length.should == 3
      Klass.machine().states.map(&:name).should == [:egg, :chick, :bird]
      Klass.machine().states().each do |s|
        s.options[:poultry].should be_true
        s.should be_kind_of(StateFu::State)
      end

      describe "merging options" do
        it "should merge options when states are mentioned more than once" do
          StateFu::Space.reset!
          Klass.machine() { states(:egg, :chick, :bird, :poultry => true) }
          machine = Klass.machine
          machine.states.length.should == 3

          # make sure they're the same states
          states_1 = machine.states
          Klass.machine(){ states( :egg, :chick, :bird, :covering => 'feathers')}
          states_1.should == machine.states

          # ensure options were merged
          machine.states().each do |s|
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
      @lambda = lambda{ Klass.machine(){ state(:egg){ event(:hatch, :to => :chick) }}}
    end

    it "should not throw an error" do
      @lambda.should_not raise_error
    end

    describe "Klass.machine(){ state(:egg){ event(:hatch, :to => :chick) }}}" do
      before() do
        Klass.machine(){ state(:egg){ event(:hatch, :to => :chick) }}
      end
      it "should add an event :hatch to the machine" do
      end
    end
  end

end


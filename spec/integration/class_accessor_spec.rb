require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::FuSpace.reset!

##
##
##

describe "A pristine class Klass with StateFu included:" do
  include MySpecHelper
  before(:each) do
    make_pristine_class 'Klass'
  end

  it "should return a new Machine bound to the class given Klass.machine()" do
    Klass.should respond_to(:machine)
    Klass.machine.should be_kind_of(StateFu::Machine)
    machine = Klass.machine
    Klass.machine.should == machine
  end

  it "should return {} given Klass.machines()" do
    Klass.should respond_to(:machines)
    Klass.machines.should == {}
  end

  it "should return [] given Klass.machine_names()" do
    Klass.should respond_to(:machine_names)
    Klass.machine_names.should == []
  end

  ##
  ##
  ##

  describe "Having called Klass.machine() with an empty block:" do
    before(:each) do
      Klass.machine do
      end
      StateFu::DEFAULT_KOAN.should == :om
    end

    it "should return a StateFu::Machine given Klass.machine()" do
      Klass.should respond_to(:machine)
      Klass.machine.should_not be_nil
      Klass.machine.should be_kind_of( StateFu::Machine )
    end

    it "should return { :om => <StateFu::Machine> } given Klass.machines()" do
      Klass.should respond_to(:machines)
      machines = Klass.machines()
      machines.should be_kind_of(Hash)
      machines.should_not be_empty
      machines.length.should == 1
      machines.keys.should == [:om]
      machines.values.first.should be_kind_of( StateFu::Machine )
    end

    it "should returns [:om] given Klass.machine_names()" do
      Klass.should respond_to(:machine_names)
      Klass.machine_names.should == [:om]
    end

    describe "Having called Klass.machine(:two) with an empty block:" do
      before(:each) do
        Klass.machine(:two) do
        end
      end

      it "should return a StateFu::Machine given Klass.machine(:two)" do
        Klass.should respond_to(:machine)
        Klass.machine(:two).should_not be_nil
        Klass.machine(:two).should be_kind_of( StateFu::Machine )
      end

      it "should return a new Machine given Klass.machine(:three)" do
        Klass.should respond_to(:machine)
        Klass.machine(:three).should be_kind_of( StateFu::Machine )
        three = Klass.machine(:three)
        Klass.machine(:three).should == three
        # StateFu::FuSpace.class_machines[Klass][:three].should == :three
      end

      it "should return { :om => <StateFu::Machine>, :two => <StateFu::Machine> } given Klass.machines()" do
        Klass.should respond_to(:machines)
        machines = Klass.machines()
        machines.should be_kind_of(Hash)
        machines.should_not be_empty
        machines.length.should == 2
        machines.keys.should include :om
        machines.keys.should include :two
        machines.values.length.should == 2
        machines.values.each { |v| v.should be_kind_of( StateFu::Machine ) }
      end

      it "should return [:om, :two] give Klass.machine_names (unordered)" do
        Klass.should respond_to(:machine_names)
        Klass.machine_names.length.should == 2
        Klass.machine_names.should include :om
        Klass.machine_names.should include :two
      end
    end

    describe "An empty class Child which inherits from Klass" do
      before() do
        Object.send(:remove_const, 'Child' ) if Object.const_defined?( 'Child' )
        class Child < Klass
        end
      end

      # sorry, Darwinism, not Lamarckism.
      it "does NOT inherit it's parent class' Machines !!" do
        Child.machine.should_not == Klass.machine
      end

      it "should know the Machine after calling Klass.machine.teach!( Child )" do
        Child.machine.should_not == Klass.machine
        Klass.machine.teach!( Child )
        Child.machine.should == Klass.machine
      end

    end
  end
end

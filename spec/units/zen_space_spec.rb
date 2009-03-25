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

  describe "Before any Machine is defined" do
    it "should return {} given StateFu::Space.class_machines()" do
      StateFu::Space.should respond_to(:class_machines)
      StateFu::Space.class_machines.should == {}
    end
  end

  describe "Having called Klass.machine() with an empty block:" do
    before(:each) do
      Klass.machine do
      end
      StateFu::DEFAULT_KOAN.should == :om
    end

    it "should return { Klass => { ... } } given StateFu::Space.class_machines()" do
      StateFu::Space.should respond_to(:class_machines)
      machines = StateFu::Space.class_machines()
      machines.keys.should == [Klass]
      machines.values.first.should be_kind_of( Hash )
    end

    it "should return { :om => <StateFu::Machine> } given StateFu::Space.class_machines[Klass]" do
      StateFu::Space.should respond_to(:class_machines)
      machines = StateFu::Space.class_machines[Klass]
      machines.should be_kind_of(Hash)
      machines.should_not be_empty
      machines.length.should == 1
      machines.keys.should == [:om]
      machines.values.first.should be_kind_of( StateFu::Machine )
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

    describe "Having called Klass.machine(:two) with an empty block:" do
      before(:each) do
        # Klass.machine.should_not be_nil
        Klass.machine(:two) do
        end
      end

      it "should return { :om => <StateFu::Machine>, :two => <StateFu::Machine> } given StateFu::Space.class_machines()" do
        StateFu::Space.should respond_to(:class_machines)
        machines = StateFu::Space.class_machines[Klass]
        machines.should be_kind_of(Hash)
        machines.should_not be_empty
        machines.length.should == 2
        machines.keys.sort.should == [:om, :two]
        machines.values.each { |v| v.should be_kind_of( StateFu::Machine ) }
      end

      describe "Having called StateFu::Space.reset!" do
        before(:each) do
          StateFu::Space.reset!
        end
        it "should return {} given StateFu::Space.class_machines()" do
          StateFu::Space.should respond_to(:class_machines)
          StateFu::Space.class_machines.should == {}
        end
      end

    end
  end
end


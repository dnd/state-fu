require File.expand_path("#{File.dirname(__FILE__)}/../helper")

StateFu::FuSpace.reset!

##
##
##
describe StateFu::FuSpace do
  include MySpecHelper

  before(:each) do
    reset!
    make_pristine_class 'Klass'
    @k = Klass.new()
  end

  describe "Before any Machine is defined" do
    it "should return {} given StateFu::FuSpace.class_machines()" do
      StateFu::FuSpace.should respond_to(:class_machines)
      StateFu::FuSpace.class_machines.should == {}
    end
  end

  describe "Having called Klass.machine() with an empty block:" do
    before(:each) do
      Klass.machine do
      end
      StateFu::DEFAULT_MACHINE.should == :state_fu
    end

    it "should return { Klass => { ... } } given StateFu::FuSpace.class_machines()" do
      StateFu::FuSpace.should respond_to(:class_machines)
      machines = StateFu::FuSpace.class_machines()
      machines.keys.should == [Klass]
      machines.values.first.should be_kind_of( Hash )
    end

    it "should return { :state_fu => <StateFu::Machine> } given StateFu::FuSpace.class_machines[Klass]" do
      StateFu::FuSpace.should respond_to(:class_machines)
      machines = StateFu::FuSpace.class_machines[Klass]
      machines.should be_kind_of(Hash)
      machines.should_not be_empty
      machines.length.should == 1
      machines.keys.should == [:state_fu]
      machines.values.first.should be_kind_of( StateFu::Machine )
    end

    it "should return { Klass => { ... } } given StateFu::FuSpace.field_names()" do
      StateFu::FuSpace.should respond_to(:field_names)
      fields = StateFu::FuSpace.field_names()
      fields.keys.should == [Klass]
      fields.values.first.should be_kind_of( Hash )
    end

    it "should return { :state_fu => :state_fu_state } given StateFu::FuSpace.field_names[Klass]" do
      StateFu::FuSpace.should respond_to(:field_names)
      fields = StateFu::FuSpace.field_names[Klass]
      fields.should be_kind_of(Hash)
      fields.should_not be_empty
      fields.length.should == 1
      fields.keys.should == [:state_fu]
      fields.values.should == [:state_fu_field]
    end

    describe "Having called Klass.machine(:two) with an empty block:" do
      before(:each) do
        # Klass.machine.should_not be_nil
        Klass.machine(:two) do
        end
      end

      it "should return { :state_fu => <StateFu::Machine>, :two => <StateFu::Machine> } given StateFu::FuSpace.class_machines()" do
        StateFu::FuSpace.should respond_to(:class_machines)
        machines = StateFu::FuSpace.class_machines[Klass]
        machines.should be_kind_of(Hash)
        machines.should_not be_empty
        machines.length.should == 2
        machines.keys.sort.should == [:state_fu, :two]
        machines.values.each { |v| v.should be_kind_of( StateFu::Machine ) }
      end

      describe "Having called StateFu::FuSpace.reset!" do
        before(:each) do
          StateFu::FuSpace.reset!
        end
        it "should return {} given StateFu::FuSpace.class_machines()" do
          StateFu::FuSpace.should respond_to(:class_machines)
          StateFu::FuSpace.class_machines.should == {}
        end
      end

    end
  end
end


require File.expand_path("#{File.dirname(__FILE__)}/../helper")

module RequirementFeatureHelper
  def account_expired?
    !! account_expired
  end

  def valid_password?
    !! valid_password
  end
end

# it_should_behave_like "!" do
shared_examples_for "not requirements" do
    describe "requirements with names beginning with no[t]_" do

    it "should return the opposite of the requirement name without not_" do
#      @obj.current_state.should == :guest
      @obj.stfu.teleport! :anonymous
      @obj.valid_password = false
      @binding.can_has_valid_password?.should == false
      @binding.can_has_not_valid_password?.should == true
      @binding.can_has_no_valid_password?.should == true
      @obj.valid_password = true
      @binding.can_has_valid_password?.should == true
      @binding.can_has_not_valid_password?.should == false
      @binding.can_has_no_valid_password?.should == false
    end

    it "should call the method directly if one exists" do
      @obj.valid_password = true
      (class << @obj; self; end).class_eval do
        define_method( :no_valid_password? ) { true }
      end
      @binding.can_has_valid_password?.should == true
      @binding.can_has_not_valid_password?.should == false
      @binding.can_has_no_valid_password?.should == true
    end

  end

end

describe "requirements" do
  before(:all) do
    reset!
    make_pristine_class('Klass')
    Klass.class_eval do
      attr_accessor :valid_password
      attr_accessor :account_expired
    end
    @machine = StateFu::Machine.new do
      initial_state :guest

      event :has_valid_password, :from => :anonymous, :to => :logged_in do
        requires :valid_password?
      end

      event :has_not_valid_password, :from => :anonymous, :to => :suspect do
        requires :not_valid_password?
      end

      event :has_no_valid_password, :from => :anonymous, :to => :suspect do
        requires :no_valid_password?
      end
      
    end
  end

  before :each do
    @obj.valid_password = true
    @obj.account_expired = false
  end

  describe "requirements defined with a machine helper" do
    before :all do
      @machine.lathe { helper RequirementFeatureHelper }
      @machine.bind!(Klass, :default)
      @obj     = Klass.new
      @binding = @obj.state_fu
    end

    it_should_behave_like "not requirements"

    it "should not have methods on the object" do
      @obj.respond_to?(:valid_password?).should == false
      @obj.respond_to?(:account_expired?).should == false
    end

    it "should have methods on the binding" do
      # this is a little misleading because theyre not evaluated on the binding ..
      @binding.respond_to?(:valid_password?).should == true
      @binding.respond_to?(:account_expired?).should == true
      @binding.respond_to?(:not_valid_password?).should == false
      @binding.respond_to?(:not_account_expired?).should == false
    end
  end

  describe "requirements defined on the object" do
    before :all do
      @machine.bind!(Klass, :default)
      @obj = Klass.new
      @binding = @obj.state_fu
      Klass.class_eval do
        include RequirementFeatureHelper
      end
    end

    it_should_behave_like "not requirements"

    it "should have methods on the object" do
      @obj.respond_to?(:valid_password?).should == true
      @obj.respond_to?(:not_valid_password?).should == false
      @obj.respond_to?(:account_expired?).should == true
      @obj.respond_to?(:not_account_expired?).should == false
    end
  end
end

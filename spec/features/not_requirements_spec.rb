require File.expand_path("#{File.dirname(__FILE__)}/../helper")

module RequirementFeatureHelper

  def account_expired_test
    false
  end

  def valid_password_test
    true
  end

  def account_expired?
    !!account_expired_test
  end

  def valid_password?
    !!valid_password_test
  end
end

describe "requirement objects" do
  include MySpecHelper
  before(:all) do
    reset!
    make_pristine_class('Klass')
    Klass.machine do
      helper RequirementFeatureHelper

      initial_state :guest

      event :login_success, :from => :guest, :to => [:logged_in, :expired] do
        requires :valid_password?
      end

      event :login_failure, :from => :guest, :to => :guest do
        execute :show_error
      end

      state :logged_in do
        requires :not_account_expired?
      end

      state :expired do
        requires :account_expired?
      end
    end
    @obj = Klass.new
    @binding = @obj.state_fu
  end

  describe "requirements with names beginning with not_" do
    it "should return the boolean opposite of the requirement name without not_" do
      @binding.evaluate_named_proc_or_method( :valid_password? ).should == true
      @binding.evaluate_named_proc_or_method( :not_valid_password? ).should == false

      @binding.account_expired?.should == false
      @binding.valid_password?.should == true

      t = @binding.login_success(:logged_in)
      t.requirements.should == [:not_account_expired?, :valid_password?]
      t.unmet_requirements.should == []
      @binding.fireable?( [:login_success,:logged_in] ).should == true
      @obj.login_success?(:logged_in).should == true
      @obj.login_success!(:logged_in).should == true
      @binding.should == :logged_in
    end
  end

end

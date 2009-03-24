require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "A simple Koan definition" do

  include MySpecHelper

  describe "When there is a koan describing user logins" do
    before(:all) do
      reset!
      make_pristine_class 'Klass'

      # TODO
      #
      # Method proxy:
      # @obj.om.helpers[:method_name] => proc
      # look for methods first on obj
      # then in on the helper
      # before raising a method_missing error.
      #
      # when executing methods from the helper,
      # use method(mname) to convert them into something
      # we can instance_eval in the context of our disciple instance :)
      #
      # maybe. or maybe that's just sick.

      # @koan_spec = lambda do
        Klass.koan( :method_proxy => true ) do

          states :new, :active, :limbo, :expired, :deleted

          event :confirm do
            from :new, :to => :confirmed, :auto => true do
              needs :email_confirmation
            end
          end

          state :confirmed do
            on_entry :send_welcome_email
          end

          event :login, :from => [:confirmed, :active], :to => :active do
            execute :handle_login do
              halt_unless :password_correct?
              halt_if     :dodgy_user_agent?
              obj.generate_new_cookie!
            end
          end

          state :active do
            on_entry :popup_banner_ads_everywhere
          end

          event :delete do
            from :ALL, :except => :deleted
            to :deleted
            after do
              obj.destroy!
            end
          end

          states :ALL do
            after(:save!)
          end

        end
      end # koan
    # end # before

    it "parsing it should not throw an error" do
      # @koan_spec.should_not raise_error()
      # @koan_spec.call()
    end

    describe ".." do
    end
  end # describe_1
end

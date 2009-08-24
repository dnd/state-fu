require File.expand_path("#{File.dirname(__FILE__)}/../helper")


describe "Transition requirement reflection" do
  include MySpecHelper

  before do
    reset!
    make_pristine_class("Klass") do
      def turban?;         false end
      def arrest_warrant?; false end
      def papers_in_order?; true end
      def papers_in_order?; true end
      def money_for_bribe?; true end
      def spacesuit?;       true end
      def plane_ticket?;    true end
      def fuel?;            true end
    end
    @machine = Klass.state_fu_machine do
      state :soviet_russia do
        requires( :papers_in_order?, :on => [:entry, :exit] )
        requires( :money_for_bribe?, :on => [:entry, :exit] )
      end

      state :america do
        requires( :no_turban?,
                  :us_visa?,
                  :on => :entry )
        requires( :no_arrest_warrant?, :on => [:entry,:exit] )
      end

      state :moon do
        requires :spacesuit?
      end

      event( :catch_plane,
             :from => states.except(:moon),
             :to   => states.except(:moon) ) do
        requires :plane_ticket?
      end

      event( :fly_spaceship,
             :from => :ALL,
             :to   => :ALL ) do
        requires :fuel?
      end

    end # machine
    @obj = Klass.new()
  end  # before

  describe "transition.valid? / transition.requirements_met?" do
    it "should be true if all requirements are met (return truth)" do
      #@obj.state_fu.next_states[:moon].entry_requirements.should == [:spacesuit?]
      
      #@obj.state_fu.fireable?([:fly_spaceship,:moon]).should == true
      @obj.can_fly_spaceship?(:moon).should == true
      #@obj.fly_spaceship(:moon).requirements_met?.should == true
      #@obj.fly_spaceship(:moon).should be_valid
    end

    it "should be false if not all requirements are met" do
      stub( @obj ).spacesuit?() { false }
      @obj.state_fu.next_states[:moon].entry_requirements.should == [:spacesuit?]
      # @obj.state_fu.evaluate(:spacesuit?).should == false
      @obj.can_fly_spaceship?(:moon).should == false
      @obj.fly_spaceship(:moon).requirements_met?.should == false
      @obj.fly_spaceship(:moon).should_not be_valid
    end
  end

  describe "flying from russia to america without one's affairs in order while wearing a turban" do
    before do
      mock( @obj ).us_visa?(anything) { false }
      mock( @obj ).no_turban?(anything) { false }
      mock( @obj ).no_arrest_warrant?(anything) { false }
      mock( @obj ).money_for_bribe?(anything) { false }
      mock( @obj ).papers_in_order?(anything) { false }
    end

    describe "when no messages are supplied for the requirements" do
      describe "given transition.unmet_requirements" do
        it "should contain a list of failing requirement names as symbols" do
          @obj.state_fu.catch_plane(:america).unmet_requirements.should == [ :papers_in_order?,
                                                                             :money_for_bribe?,
                                                                             :no_turban?,
                                                                             :us_visa?,
                                                                             :no_arrest_warrant? ]
        end
      end # unmet requirements

      describe "given transition.unmet_requirement_messages" do
        it "should return a list of nils" do
          @obj.state_fu.catch_plane(:america).unmet_requirement_messages.should ==
            [:papers_in_order?, :money_for_bribe?, :no_turban?, :us_visa?, :no_arrest_warrant?]
        end
      end # unmet_requirement_messages
    end

    describe "when a message is supplied for the money_for_bribe? entry requirement" do
      before do
        Klass.state_fu_machine do
          state :soviet_russia do
            requires( :money_for_bribe?, :message => "This guard is thirsty! Do you have anything to declare?" )
          end
        end
      end

      describe "given transition.unmet_requirements" do
        it "should still contain a list of failing requirement names as symbols" do
          @obj.state_fu.catch_plane(:america).unmet_requirements.should == [ :papers_in_order?,
                                                                             :money_for_bribe?,
                                                                             :no_turban?,
                                                                             :us_visa?,
                                                                             :no_arrest_warrant? ]
        end
      end

      describe "given transition.unmet_requirement_messages" do
        it "should contain a list of nils plus the requirement message for money_for_bribe? as a string" do
          @obj.state_fu.catch_plane(:america).unmet_requirement_messages.should ==
            [:papers_in_order?,
             "This guard is thirsty! Do you have anything to declare?",
             :no_turban?,
             :us_visa?,
             :no_arrest_warrant?]
        end
      end

    end
  end # flying with a turban

  describe "transition.unmet_requirements" do
    it "should be empty when all requirements are met" do
      @obj.state_fu.fly_spaceship(:moon).unmet_requirements.should == []
    end

    describe "when a message is supplied for the requirement" do
      it "should contain a list of the requirement failure messages as strings" do
        mock( @obj ).spacesuit?(anything) { false }
        mock( @obj ).fuel?(anything) { false }
        @obj.state_fu.fly_spaceship(:moon).unmet_requirements.should == [:spacesuit?, :fuel?]
      end
    end
  end


  describe "transition.unmet_requirement_messages" do
    describe "when a string message is defined for one of two unmet_requirements" do
      before do
        stub( @obj ).spacesuit?() { false }
        stub( @obj ).fuel?() { false }
        @msg = "You got no spacesuit."
        @machine.requirement_messages[:spacesuit?] = @msg
      end

      it "should return an array with the requirement message and nil" do
        t = @obj.state_fu.fly_spaceship(:moon)
        t.unmet_requirements.length.should == 2
        messages = t.unmet_requirement_messages
        messages.should be_kind_of( Array )
        messages.length.should == 2
        messages.strings.length.should == 1
        messages.symbols.length.should == 1
        messages.strings.first.should == @msg
        messages.symbols.first.should == :fuel?
      end
    end

    describe "when a proc message is defined for one of two unmet_requirements" do
      before do
        stub( @obj ).spacesuit?() { false }
        stub( @obj ).fuel?() { false }
      end
      describe "when the arity of the proc is 1" do
        before do
          @msg = lambda { |trans| "I am a #{trans.class} and I fail it" }
          @machine.requirement_messages[:spacesuit?] = @msg
        end

        it "should return an array with the requirement message and nil" do
          t = @obj.state_fu.fly_spaceship(:moon)
          t.unmet_requirements.length.should == 2
          messages = t.unmet_requirement_messages
          messages.should be_kind_of( Array )
          messages.length.should == 2
          messages.strings.length.should == 1
          messages.strings.first.should be_kind_of( String )
          messages.strings.first.should == "I am a StateFu::Transition and I fail it"
          messages.symbols.first.should == :fuel?
        end
      end # arity 1

      describe "when the arity of the proc is 0" do
        before do
          @msg = lambda { "I am a #{self.class} and I fail it" }
          @machine.requirement_messages[:spacesuit?] = @msg
        end

        it "should return an array with the requirement message and nil" do
          t = @obj.state_fu.fly_spaceship(:moon)
          t.unmet_requirements.length.should == 2
          messages = t.unmet_requirement_messages
          messages.should be_kind_of( Array )
          messages.length.should == 2
          messages.strings.length.should == 1
          messages.strings.first.should be_kind_of( String )
          messages.strings.first.should == "I am a StateFu::Executioner and I fail it"
          messages.symbols.first.should == :fuel?
        end
      end # arity 1

    end # 1 proc msg of 2
    describe "when a symbol message is defined for one of two unmet_requirements" do
      before do
        #stub( @obj ).spacesuit?() { false }
        #stub( @obj ).fuel?() { false }
        @machine.requirement_messages[:spacesuit?] = :no_spacesuit_msg_method
        Klass.class_eval do
          attr_accessor :arg
          def spacesuit?; false end
          def fuel?; false end
            
          def no_spacesuit_msg_method
            # raise ArgumentError unless t.is_a?( StateFu::Transition )
            "You can't go to the #{t.target.name} without a spacesuit!"
          end
        end
      end

      describe "when there is no named proc on the machine matching the symbol" do

        it "should call the method on @obj given transition.evaluate() with the method name" do
          
          # @obj.method( :no_spacesuit_msg_method ).arity.should == 1
          t = @obj.state_fu.fly_spaceship(:moon)
          
          #x = @obj.state_fu.evaluate(:no_spacesuit_msg_method )
          @obj.arg.should == nil
          t.unmet_requirements.should == /You can't go to the moon/
        end

        it "should call t.evaluate_named_proc_or_method(:no_spacesuit_msg_method)" do
          t = @obj.state_fu.fly_spaceship(:moon)
          t.unmet_requirements.length.should == 2
          stub( t ).evaluate( anything) { false }

          mock( t ).evaluate(:no_spacesuit_msg_method){ ":)" }
          messages = t.unmet_requirement_messages
          messages.should include( ":)" )
        end

        it "should call the method on @obj with the name of the symbol, passing it a transition" do
          t = @obj.state_fu.fly_spaceship(:moon)
          t.unmet_requirements.length.should == 2
          messages = t.unmet_requirement_messages
          @obj.arg.should == nil
        end

        it "should return the result of the method execution as the message" do
          t = @obj.state_fu.fly_spaceship( :moon )
          t.unmet_requirements.length.should == 2
          messages = t.unmet_requirement_messages
          messages.length.should == 2
          messages.strings.length.should == 1
          #@obj.arg.should == t
          messages.strings[0].should == "You can't go to the moon without a spacesuit!"
        end
      end # no named proc
    end   # symbol message
  end     # transition.unmet_requirement_messages
end




require File.join(File.dirname(__FILE__), 'spec_helper')

#
# Door
#

describe "a simple machine, a door which opens and shuts:" do
  before :all do

    # class Door
    make_pristine_class('Door') do
      include StateFu
      
      attr_accessor :locked
      
      def locked?
        #raise "!"
        !!locked
      end

      machine do
        event :shut, :transitions_from => :open,   :to => :closed
        event :open, :transitions_from => :closed, :to => :open, 
                             :requires => :not_locked?,
                              :message => "Sorry, it's locked."
      end
    end
  end # before

  describe "Door's state machine" do
    it "have two states, :open and :closed" do
      Door.machine.states.names.should == [:open, :closed]
    end

    it "have two events, :shut and :open" do
      Door.machine.events.names.should == [:shut, :open]
    end

    it "have an initial state of :open, the first state defined" do
      Door.machine.initial_state.name.should == :open
    end

    it "have an initial state of :open, the first state defined" do
      Door.machine.initial_state.name.should == :open
    end
    
    it "have a requirement :not_locked? for the :open event" do
      Door.machine.events[:open].requirements.should == [:not_locked?]
    end

    it "have a requirement_message 'Sorry, it's locked.' for :not_locked?" do
      Door.machine.requirement_messages[:not_locked?].should == "Sorry, it's locked."
    end

    it "reflect on event origin and target states" do
      event = Door.machine.events[:open]
      event.origin_names.should == [:closed]
      event.target_names.should == [:open]
      event.simple?.should == true   # because there's only one possible target
      event.origin.should == :closed # because there's only one origin
      event.target.should == :open   # because there's only one target
      event.machine.should == Door.machine
    end

  end

  describe "door" do
    before do
      @door = Door.new
    end

    it "transition from :open to :closed on #shut!" do
      @door.current_state.should == :open
      @door.shut!.should be_true
      @door.current_state.should == :closed
    end

    it "raise a StateFu::InvalidTransition if #shut! is called when it's already closed" do
      @door.current_state.should == :open
      @door.shut!.should be_true
      @door.current_state.should == :closed
      lambda do 
        t = @door.shut!
        t.origin.should == :open
      end.should raise_error(StateFu::InvalidTransition)
    end

    it "tell you why it won't open if you rescue the error" do
      @door.shut!
      @door.locked = true
      @door.locked?.should be_true
      begin
        @door.open!
      rescue StateFu::RequirementError => e
        e.to_a.should == ["Sorry, it's locked."]
        e.to_h.should == {:not_locked? => "Sorry, it's locked."}
      end
    end

    it "tell you why it won't open if you ask nicely" do
      @door.shut!
      @door.locked = true
      @door.locked?.should be_true
      
      transition = @door.state_fu.transition :open
      transition.requirement_errors.should == {:not_locked? => "Sorry, it's locked."}
    end


    # TODO save this for later ...............
    describe "#state_fu_binding" do
      it "be a StateFu::Binding" do
        @door.state_fu_binding.should be_kind_of StateFu::Binding
      end

      it "have a current_state which is initially :open" do
        @door.state_fu_binding.current_state.should == :open
      end

      it "have one event, :shut" do
        @door.state_fu_binding.events.should == [:shut]
      end

      it "have a list of #valid_transitions" do
        @door.state_fu_binding.valid_transitions.should be_kind_of(StateFu::TransitionQuery)
        @door.state_fu_binding.valid_transitions.length.should == 1
        t = @door.state_fu_binding.valid_transitions.first
        t.origin.name.should == :open
        t.target.name.should == :closed
        t.event.name.should  == :shut
      end
    end

    describe "#state_fu" do
      it "be the same as door#state_fu_binding" do
        @door.state_fu.should == @door.state_fu_binding
      end
    end

    describe "#stfu" do
      it "be the same as door#state_fu_binding" do
        @door.stfu.should == @door.state_fu_binding
      end
    end

    describe "#fu" do
      it "be the same as door#state_fu_binding" do
        @door.fu.should == @door.state_fu_binding
      end
    end

  end
end

#
# Heart
#

describe "a simple machine, a heart which beats:" do

  before :all do
    make_pristine_class('Heart') do
      include StateFu

      def heartbeats
        @heartbeats ||= []
      end

      machine do
        cycle :state => :beating, :on => :beat do
          causes(:heartbeat) { heartbeats << :thumpthump }
        end
        event :stop, :from => { :beating => :stopped }
      end
    end
  end # before

  describe "the machine" do
    it "have two states, :beating and :stopped" do
      Heart.machine.states.names.should == [:beating,:stopped]
    end

    it "have two events, :beat and :stop" do
      Heart.machine.events.names.should == [:beat, :stop]
    end

    it "have an initial state of :beating" do
      Heart.machine.initial_state.name.should == :beating
    end
  end

  describe "it" do
    before do
      @heart = Heart.new
    end

    it "cause a heartbeat on heart#beat!" do
      @heart.heartbeats.should == []
      @heart.beat!.should be_true
      @heart.heartbeats.should == [:thumpthump]
    end

    it "raise an InvalidTransition if it tries to beat after it's stopped" do
      @heart.stop!
      @heart.current_state.should == :stopped
      lambda { @heart.beat! }.should raise_error(StateFu::InvalidTransition)
    end

    it "transition to :stopped on #next!" do
      @heart.current_state.should == :beating
      @heart.state_fu.transitions.not_cyclic.length.should == 1
      @heart.state_fu.next_transition.should_not == nil
      @heart.state_fu.next_state.should_not == nil
      @heart.next_state!
      @heart.current_state.should == :stopped
    end

    it "transition to :stopped on #next_state!" do
      @heart.current_state.should == :beating
      @heart.next_state!
      @heart.current_state.should == :stopped
    end

    it "transition to :stopped on #next_transition!" do
      @heart.current_state.should == :beating
      @heart.next_state!
      @heart.current_state.should == :stopped
    end

  end
end

#
# Traffic Lights
#

describe "a simple machine, a set of traffic lights:" do
  before :all do

    make_pristine_class('TrafficLights') do
      include StateFu
      attr_reader :photos

      def initialize
        @photos          = []
      end

      def red_light_camera
        @photos << :click
      end

      machine do
        state :go,      :colour => :green
        state :caution, :colour => :amber
        state :stop,    :colour => :red do
          on_entry :red_light_camera
        end

        connect_states :go, :caution, :stop, :go
      end
    end
  end # before

  describe "the machine:" do
    it "have three states, :go, :caution, and :stop" do
      TrafficLights.machine.states.names.should == [:go, :caution, :stop]
    end

    it "have three events :go_to_caution, :caution_to_stop, and :stop_to_go" do
      TrafficLights.machine.events.names.should == [:go_to_caution, :caution_to_stop, :stop_to_go]
    end

    it "have an initial_state of :go" do
      TrafficLights.machine.initial_state.name.should == :go
    end

    describe "the states' options" do
      it "have an appropriate colour" do
        TrafficLights.machine.states[:go]     [:colour].should == :green
        TrafficLights.machine.states[:caution][:colour].should == :amber
        TrafficLights.machine.states[:stop]   [:colour].should == :red
      end
    end
  end

  describe "it" do
    before do
      @lights = TrafficLights.new
    end

    it "transition from :go to :caution on #go_to_caution!" do
      @lights.current_state.should == :go
      @lights.go_to_caution!
      @lights.current_state.should == :caution
    end

    it "transition from :go to :caution on #next!" do
      @lights.current_state.should == :go
      @lights.next!
      @lights.current_state.should == :caution
    end

    it "transition from :go to :caution on #next_state!" do
      @lights.current_state.should == :go
      @lights.next_state!
      @lights.current_state.should == :caution
    end

    it "transition from :go to :caution on #fire_next_transition!" do
      @lights.current_state.should == :go
      @lights.fire_next_transition!
      @lights.current_state.should == :caution
    end

   describe "when entering the :stop state" do
     it "fire :red_light_camera" do
        @lights.next!
        @lights.photos.should be_empty
        @lights.next!
        @lights.current_state.should == :stop
        @lights.photos.length.should == 1
      end
    end
  end
end

#
# Recorder
#
describe "arguments given to different method signatures" do
  before :all do
    make_pristine_class('Recorder') do
      include StateFu
      attr_accessor :received

      def initialize
        @received = {}
      end

      # arguments passed to methods / procs:
      # these method signatures get a transition
      def a1(t)         received[:a1] = [t] end
      def b1(t=nil)     received[:b1] = [t] end
      def c1(*t)        received[:c1] = [t] end

      # these method signatures get a transition and a list of arguments
      def a2(t,a)       received[:a2] = [t,a] end
      def b2(t,a=nil)   received[:b2] = [t,a] end
      def c2(t,*a)      received[:c2] = [t,a] end

      # these method signatures get a transition, a list of arguments, 
      # and the object which owns the machine
      def a3(t,a,o)     received[:a3] = [t,a,o] end
      def b3(t,a,o=nil) received[:b3] = [t,a,o] end
      def c3(t,a,*o)    received[:c3] = [t,a,o] end

      machine do
        cycle :state => :observing, :on => :observe do
          trigger :a1, :b1, :c1, :a2, :b2, :c2, :a3, :b3, :c3
        end
      end

    end
  end # before
  
  describe "the machine" do
    it "have an event :observe which is a #cycle?" do
      Recorder.machine.events[:observe].cycle?.should be_true      
    end
    
    it "have a list of execute hooks" do
      Recorder.machine.events[:observe].hooks[:execute].should == [:a1, :b1, :c1, :a2, :b2, :c2, :a3, :b3, :c3]
    end
  end

  describe "it" do
    before do
      @recorder = Recorder.new
    end

    it "fire a transition on #observe!" do
      t = @recorder.observe!
      results = @recorder.received
      t.should be_kind_of(StateFu::Transition)
      t.should be_complete
    end
    
    describe "observing method calls on #observe!" do
      before do
        @t = @recorder.observe!
        @results = @recorder.received
      end
      
      it "call the event's :execute hooks on #observe!" do
        @results.keys.should =~ [:a1, :b1, :c1, :a2, :b2, :c2, :a3, :b3, :c3]
      end
    
      describe "methods which expect one argument" do
        it "receive a StateFu::Transition" do
          @results[:a1].should == [@t]
          @results[:b1].should == [@t]
          @results[:c1].should == [[@t]]
        end
      end

      describe "methods which expect two arguments" do
        it "receive a StateFu::Transition and an argument list" do
          @results[:a2].should == [@t, @t.args]
          @results[:b2].should == [@t, @t.args]
          @results[:c2].should == [@t, [@t.args]]
        end
      end

      describe "methods which expect three arguments" do
        it "receive a StateFu::Transition, an argument list and the recorder" do
          @results[:a3].should == [@t, @t.args, @recorder]
          @results[:b3].should == [@t, @t.args, @recorder]
          @results[:c3].should == [@t, @t.args, [@recorder]]      
        end
      end
    end
  end
end

#
# Pokies
#

describe "sitting at a poker machine" do
  
  before :all do
    make_pristine_class('PokerMachine') do
      
      attr_accessor :silly_noises_inflicted
      
      def insert_coins n
        @credits = n * PokerMachine::CREDITS_PER_COIN
      end

      # sets coins to 0 and returns what it was
      def refund_coins
        (self.credits, x = 0, self.credits / PokerMachine::CREDITS_PER_COIN)[1]
      end
                
      def play_a_silly_noise
        @silly_noises_inflicted << [:silly_noise]
      end
      
      # an array with the accessors (StateFu::Bindings) 
      # for each of the wheels' state machines, for convenience
      def wheels
        [wheel_one, wheel_two, wheel_three] 
      end

      def wheels_spinning?
        wheels.any?(&:spinning?)
      end
      
      def display
        wheels.map(&:current_state_name)
      end
      
      def wait
        while wheels_spinning?
          spin_wheels! 
        end           
        stop_spinning!   
      end
                        
      PokerMachine::CREDITS_TO_PLAY  = 5
      PokerMachine::CREDITS_PER_COIN = 5

      attr_accessor :credits

      def initialize
        @credits                = 0
        @silly_noises_inflicted = []
      end
      
      machine do
        # adds a hook to the machine's global after slot 
        after_everything :play_a_silly_noise
        
        # Define helper methods with 'proc' or its alias 'define'. This is
        # implicit when you supply a block and a symbol for an event or state
        # hook, a requirement, or a requirement failure message. 
        #
        # Named procs are "machine-local": they are available in any other
        # block evaluated by StateFu for a given machine, but are not defined
        # on the stateful class itself.
        #     
        # Use them to extend the state machine DSL without cluttering up your
        # classes themselves.
        #    
        # If you want a method which spans multiple machines (eg 'wheels',
        # above) or which is available to your object in any context, define
        # it as a standard method. You will then be able to access it in any
        # of your state machines.
        named_proc(:wheel_states) { wheels.map(&:current_state) }        
        named_proc(:wheels_stopped?) do
          !wheels.any?(&:spinning?)
        end
                
        state :ready do          

          event :pull_lever, :transitions_to => :spinning do
            # The execution context always provides handy access to all the
            # methods of the PokerMachine instance - however, constants must
            # still be qualified.
            requires(:enough_credits) { self.credits >= PokerMachine::CREDITS_TO_PLAY }
            triggers(:deduct_credits) { self.credits -= PokerMachine::CREDITS_TO_PLAY }
            triggers(:spin_wheels)    { [wheel_one, wheel_two,wheel_three].each(&:start!) } 
            # if we enable this line, the machine will #wait automatically
            # so that merely pulling the lever causes it to return to the ready state:
            #
            # after :wait            
          end # :pull_lever event                    
        end # :ready state
        
        state :spinning do              
          cycle :spin_wheels do
            # executes after the transition has been accepted
            after do
              wheels.each do |wheel| 
                if wheel.spinning?
                  wheel.spin!
                end
              end              
            end # execute
          end # :spinning state

          event :stop_spinning, :to => :ready do 
            requires :wheels_stopped? 
            execute :payout do
              if wheel_states == wheel_states.uniq
                self.credits += wheel_states.first[:value]
              end             
            end
          end # :stop_spinning event                    
        end # spinning state                
      end # default machine 
      
      [:one, :two, :three].each do |wheel|
        machine "wheel_#{wheel}" do
                    
          state :bomb,     :value => -5
          state :cherry,   :value =>  5
          state :smiley,   :value => 10
          state :gold,     :value => 15          

          state :spinning do
            cycle :spin do
              execute do
                silly_noises_inflicted << :spinning_noise                    
              end
              after do
                if rand(3) == 0                   
                  # we use binding.stop! rather than self.stop! here
                  # to disambiguate which machine we're sending the event to.
                  #
                  # .binding yields a StateFu::Binding, which has all the same
                  # magic methods as @pokie, but is explicitly for one machine, 
                  # and one @pokie.
                  # 
                  # @pokie.stop! would always cause the same wheel to stop 
                  # (the first one, becuase it was defined first, and automatically 
                  # defined methods never clobber any pre-existing methods) -
                  # which isn't what we want here.
                  binding.stop!([:bomb, :cherry, :smiley, :gold].rand) 
                end
              end
            end
          end
          
          initial_state states.except(:spinning).rand
                                    
          event :start, :from => states.except(:spinning), :to => :spinning
          event :stop,  :from => :spinning, :to => states.except(:spinning)
          
        end # machine :cell_#{cell}
      end # each cell
    end # PokerMachine  
  end # before 
  
  describe "the state machine" do
  end
  
  before :each do
    @pokie = PokerMachine.new
  end
  
  # just a sanity check for method_missing
  it "doesn't talk to you" do
    lambda { @pokie.talk_to_me }.should raise_error(NoMethodError)
  end
    
  it "you need credits to pull the lever" do
    @pokie.state_fu!
    @pokie.credits.should == 0
    @pokie.state_fu!
    @pokie.can_pull_lever?.should == false
    lambda { @pokie.pull_lever! }.should raise_error(StateFu::RequirementError)
  end

  it "has three wheels" do
    @pokie.wheels.length.should == 3
  end
  
  it "displays three icons" do
    @pokie.display.should be_kind_of(Array)
    @pokie.display.map(&:class).should == [Symbol, Symbol, Symbol]
    (@pokie.display - [:bomb, :cherry, :smiley, :gold]).should be_empty
  end
  
  describe "putting in 20 coins" do
    before do
      @pokie.insert_coins(20)
    end

    it "gives you 100 credits" do
      @pokie.credits.should == 100
    end
  
    describe "then pulling the lever" do

      it "spins the icons" do
        @pokie.pull_lever!
        @pokie.display.should == [:spinning, :spinning, :spinning]
      end

      it "takes away credits" do
        credits_before_pulling_lever = @pokie.credits
        @pokie.pull_lever!
        @pokie.credits.should == credits_before_pulling_lever - PokerMachine::CREDITS_TO_PLAY
      end

      it "makes a silly noise" do
        lambda { @pokie.pull_lever! }.should change(@pokie.silly_noises_inflicted, :length)
      end
      
      it "wont let you pull it again while it's still spinning" do
        @pokie.pull_lever!
        @pokie.spinning?.should be_true
        @pokie.can_pull_lever?.should == nil
        lambda{ @pokie.pull_lever! }.should raise_error(StateFu::InvalidTransition)
      end      
      
      it "makes a spinning sound while you wait" do
        @pokie.pull_lever!
        noises_before = @pokie.silly_noises_inflicted
        @pokie.wait
        (@pokie.silly_noises_inflicted).should include(:spinning_noise)
      end
            
      it "it stops spinning after a little #wait" do
        @pokie.pull_lever!        
        @pokie.wait
        @pokie.spinning?.should be_false
      end
      
      it "gives you more credits if all the icons are the same" do
        @pokie.pull_lever!
        @pokie.wheel_one.stop!   :smiley
        @pokie.wheel_two.stop!   :smiley
        @pokie.wheel_three.stop! :smiley
        @pokie.wait
        @pokie.credits.should == 105
      end 
    end        
  end    
end




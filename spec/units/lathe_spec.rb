require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::Lathe do
  include MySpecHelper

  before do
    reset!
    make_pristine_class('Klass')
    @machine = Object.new()
    @state   = Object.new()
    @event   = Object.new()

    @lathe = StateFu::Lathe.new( @machine )
    @states = [].extend StateFu::StateArray
    stub( @machine ).states() { @states }
    @events = [].extend StateFu::EventArray
    stub( @machine ).events() { @events }
  end

  describe "constructor" do
    it "should create a new Lathe given valid arguments" do
      lathe = StateFu::Lathe.new( @machine )
      lathe.should be_kind_of( StateFu::Lathe )
      lathe.machine.should  == @machine
      lathe.sprocket.should == nil
      lathe.options.should  == {}
    end

    it "should accept a sprocket (state / event ) and if given one, be a child" do
      options = {}
      mock( @state ).apply!( options ) {}
      lathe = StateFu::Lathe.new( @machine, @state )
      lathe.should be_kind_of( StateFu::Lathe )
      lathe.machine.should  == @machine
      lathe.sprocket.should == @state
      lathe.options.should  == {}
      lathe.should be_child
    end
  end

  describe "lathe instance with no sprocket (master lathe for a machine)" do
    before do
    end

    it "should be master?" do
      @lathe.should be_master
      @lathe.should_not be_child
    end

    describe "defining a state with .state" do

      it "should add a state to the lathe's machine.states if the named state does not exist" do
        @lathe.state( :wibble )
        @machine.states.should_not be_empty
        @machine.states.length.should == 1
        s = @machine.states.first
        s.should be_kind_of( StateFu::State )
        s.name.should == :wibble
      end

      it "should create a child lathe and apply the options and block if supplied" do
        options = {:banana => :flower}
        @state = Object.new()
        @child = Object.new()
        # can't mock the block :(
        mock( StateFu::State ).new( @machine, :wobble, options ) { @state }
        mock( StateFu::Lathe ).new( @machine, @state, options ) { @child }
        mock( @child )
        @lathe.state( :wobble, options )
      end

      it "should update the named state if it exists" do
        @lathe.state( :wibble, { :nick => :wobble } )
        @machine.states.should_not be_empty
        @machine.states.length.should == 1
        s = @machine.states.first
        @lathe.state( :wibble, { :meta => :voodoo } ).should == s
        s.options[:meta].should == :voodoo
        s.options[:nick].should == :wobble
      end

    end # .state

    describe "defining multiple states with .states" do

      it "should add all states named to the machine if they dont exist" do
        @lathe.states :a, :b, :c, {:group => :alphabet} do
          requires :jackson_five
        end
        @machine.states.length.should == 3
        @machine.states.map(&:name).should == [:a, :b, :c]
        @machine.states.each {|s| s.options[:group].should == :alphabet }
        @machine.states.each {|s| s.entry_requirements.should include(:jackson_five) }
      end

      it "should apply the block / options to each named state if it already exists" do
        @lathe.state :lemon do
          requires :squinty_face
        end
        @lathe.states :mango, :orange, :lemon, {:group => :fruit } do
          requires :knife
          on_entry :peel
        end
        @lathe.states :orange, :lemon, :mandarin,  { :type  => :citrus } do
          requires :juicer
          on_entry :juice
        end
        states = @machine.states
        states[:mango   ].options.should == { :group => :fruit }
        states[:lemon   ].options.should == { :group => :fruit, :type => :citrus }
        states[:mandarin].options.should == { :type => :citrus }
        states[:mango   ].entry_requirements.should == [:knife]
        states[:lemon   ].entry_requirements.should == [:squinty_face, :knife, :juicer]
        states[:mandarin].entry_requirements.should == [:juicer]
        states[:mango   ].hooks[:entry].should == [:peel]
        states[:lemon   ].hooks[:entry].should == [:peel, :juice]
        states[:mandarin].hooks[:entry].should == [:juice]
      end

      it "should apply to all existing states given :ALL" do
        @lathe.states :hot, :cold
        names = []
        @lathe.states :ALL do |s|
          names << s.name
        end
        names.should == [:hot, :cold]
      end

      it "should apply to all existing states given no arguments" do
        @lathe.states :hot, :cold
        names = []
        @lathe.states do |s|
          names << s.name
        end
        names.should == [:hot, :cold]
      end

      # TODO
      it "should apply to all existing states except those named given :except => [...]" do
        @lathe.states :hot, :cold, :warm

        names = []
        @lathe.states :ALL, :except => :warm do |s|
          names << s.name
        end
        names.should == [:hot, :cold]

        names = []
        @lathe.states :ALL, :except => [:hot, :cold] do |s|
          names << s.name
        end
        names.should == [:warm]

      end

    end # states

    describe "defining an event with .event" do

      it "should add a event to the lathe's machine.events if the named event does not exist" do
        @lathe.event( :wibble )
        @machine.events.should_not be_empty
        @machine.events.length.should == 1
        s = @machine.events.first
        s.should be_kind_of( StateFu::Event )
        s.name.should == :wibble
      end

      it "should create a child lathe and apply the options and block if supplied" do
        options = {:banana => :flower}
        @event = Object.new()
        @child = Object.new()
        # can't mock the block :(
        mock( StateFu::Event ).new( @machine, :wobble, options ) { @event }
        mock( StateFu::Lathe ).new( @machine, @event, options ) { @child }
        mock( @child )
        @lathe.event( :wobble, options )
      end

      it "should update the named event if it exists" do
        @lathe.event( :wibble )
        @machine.events.should_not be_empty
        @machine.events.length.should == 1
        s = @machine.events.first
        @lathe.event( :wibble, { :meta => :voodoo } ).should == s
        s.options[:meta].should == :voodoo
      end

      it "should create states mentioned in the event and add them to machine.states" do
        @machine = StateFu::Machine.new( :snoo )
        @lathe = StateFu::Lathe.new( @machine )

        @lathe.event(:wobble, :from => [:a, :b], :to => :c )
        @machine.events.should_not be_empty
        @machine.events.length.should == 1
        @machine.events.first.name.should == :wobble
        @machine.states.length.should == 3
        @machine.states.map(&:name).sort_by {|x| x.to_s }.should == [ :a, :b, :c]
        @machine.events[:wobble].origins.map(&:name).should == [:a,:b]
        @machine.events[:wobble].targets.map(&:name).should == [:c]
      end

    end # .event

    describe "defining multiple events with .events" do

      it "should add all events named to the machine if they dont exist" do
        @lathe.event :tickle
        @lathe.events :hit, :smack, :punch, {:group => :acts_of_violence} do
          requires :strong_stomach
        end
        e = @machine.events
        e.length.should == 4
        e.map(&:name).should == [:tickle, :hit, :smack, :punch]
        e[:tickle].options[:group].should == nil
        e[:punch ].options[:group].should == :acts_of_violence
        e[:tickle].requirements.should == []
        e[:punch ].requirements.should == [:strong_stomach]
      end

      it "should apply the block / options to each named event if it already exists" do
        @lathe.event :fart, { :socially_acceptable => false } do
          requires :tilt_to_one_side
          after :inhale_through_nose
        end

        @lathe.event :smile, { :socially_acceptable => true } do
          requires :teeth
          after :close_mouth
        end

        @lathe.events :smile, :fart, { :group => :human_actions } do
          requires :corporeal_body, :free_will
          after :blink
        end
        e = @machine.events
        e[:fart].options[:socially_acceptable].should == false
        e[:smile].options[:socially_acceptable].should == true
        e[:fart].requirements.should == [:tilt_to_one_side, :corporeal_body, :free_will]
        e[:smile].requirements.should == [:teeth, :corporeal_body, :free_will]
        e[:fart].hooks[:after].should == [:inhale_through_nose, :blink]
        e[:smile].hooks[:after].should == [:close_mouth, :blink]
      end

      it "should apply to all existing events given :ALL" do
        @lathe.events :spit, :run
        names = []
        @lathe.events :ALL do |s|
          names << s.name
        end
        names.should == [:spit, :run]
      end

      it "should apply to all existing events given no arguments" do
        @lathe.events :dance, :juggle
        names = []
        @lathe.events do |s|
          names << s.name
        end
        names.should == [:dance, :juggle]
      end

      # TODO
      it "should apply to all existing events except those named given :except => [...]" do
        @lathe.events :wink, :bow, :salute

        names = []
        @lathe.events :ALL, :except => :salute do |s|
          names << s.name
        end
        names.should == [:wink, :bow]

        names = []
        @lathe.events :ALL, :except => [:bow, :wink] do |s|
          names << s.name
        end
        names.should == [:salute]

      end

    end # events

    describe "initial_state" do

      it "should set the initial state to its argument, creating if it does not exist" do
        @machine.instance_eval do
          class << self
            attr_accessor :initial_state
          end
        end
        @machine.states.should be_empty
        @lathe.initial_state :bambi
        @machine.states.should_not be_empty
        @machine.states.length.should == 1
        @machine.states.first.name.should == :bambi
        @machine.initial_state.name.should == :bambi
        @lathe.initial_state :thumper
        @machine.states.length.should == 2
        @machine.states.map(&:name).should == [:bambi, :thumper]
        @machine.states.last.name.should == :thumper
        @machine.initial_state.name.should == :thumper
      end
    end

    describe "helper" do
      it "should call machine.helper *args" do
        mock( @machine ).helper( :fee, :fi, :fo, :fum )
        @lathe.helper( :fee, :fi, :fo, :fum )
      end
    end

  end # master lathe instance

  # child lathe - created and yielded within nested blocks in a
  # machine definition
  describe "a child lathe for a state" do
    before do
      @master = @lathe
      @state  = @lathe.state(:a)
      @lathe  = StateFu::Lathe.new( @machine, @state )
    end

    describe ".cycle( evt_name )" do
      before do
        @machine = StateFu::Machine.new( :snoo )
        @master  = StateFu::Lathe.new( @machine )
        @state   = @master.state(:a)
        @lathe   = StateFu::Lathe.new( @machine, @state )
      end

      it "should create a named event from and to the lathe's sprocket (state)" do

        @machine.events.should be_empty
        @machine.states.length.should == 1
        @lathe.cycle(:rebirth)
        @machine.events.should_not be_empty
        @machine.states.length.should == 1
        cycle = @machine.events.first
        cycle.should be_kind_of( StateFu::Event )
        cycle.origins.should == [@state]
        cycle.targets.should == [@state]
      end

      it "should create an event with a default name if given no name" do
        @machine.events.should be_empty
        @machine.states.length.should == 1
        @lathe.cycle
        @machine.events.should_not be_empty
        @machine.states.length.should == 1
        e = @machine.events.first
        e.name.should == :cycle_a
        e.origins.should == [@state]
        e.targets.should == [@state]
      end

    end

    describe ".event" do
      it "should create any states mentioned which do not exist and add them to machine.states" do
        mock( @machine ).find_or_create_states_by_name([:a]) { [:a] }
        mock( @machine ).find_or_create_states_by_name([:b]) { [:b] }
        event = @lathe.event( :go, :from => :a, :to => :b )
        event.origins.should == [:a]
        event.targets.should == [:b]
      end
    end

    describe ".requires()" do

      before do
        @state.exit_requirements.should == []
        @state.entry_requirements.should == []
      end

      it "should add :method_name to state.entry_requirements given a name" do
        @lathe.requires( :method_name )
        @state.entry_requirements.should == [:method_name]
        @state.exit_requirements.should == []
      end


      it "should add :method_name to state.entry_requirements given a name and :on => :exit" do
        @lathe.requires( :method_name, :on => :exit )
        @state.exit_requirements.should == [:method_name]
        @state.entry_requirements.should == []
      end

      it "should add :method_name to entry_requirements and exit_requirements given a name and :on => [:entry, :exit]" do
        @lathe.requires( :method_name, :on => [:entry, :exit] )
        @state.exit_requirements.should == [:method_name]
        @state.entry_requirements.should == [:method_name]
      end

      it "should add multiple method_names if more than one is given" do
        @lathe.requires( :method_one, :method_two )
        @lathe.requires( :method_three, :method_four, :on => [:exit] )
        @state.entry_requirements.should == [:method_one, :method_two]
        @state.exit_requirements.should  == [:method_three, :method_four]
      end

      it "should add to machine.named_procs if a block is given" do
        class << @machine
          attr_accessor :named_procs
        end
        @machine.named_procs = {}
        block = lambda { puts "wee" }
        @machine.named_procs.should == {}
        @lathe.requires( :method_name, :on => [:entry, :exit], &block )
        @state.exit_requirements.should == [:method_name]
        @state.entry_requirements.should == [:method_name]
        @machine.named_procs[:method_name].should == block
      end

    end
  end

  describe "a child lathe for an event" do
    before do
      stub( @machine ).find_or_create_states_by_name([:a]) { [:a] }
      stub( @machine ).find_or_create_states_by_name([:b]) { [:b] }

      @master = @lathe
      @event  = @lathe.event( :go )
      @lathe  = StateFu::Lathe.new( @machine, @event )
    end

    describe ".from" do

      it "should create any states mentioned which do not exist and add them to machine.states"
      it "should set the origins to the result of machine.find_or_create_states_by_name" do
        mock( @machine ).find_or_create_states_by_name([:a, :b]) { [:a, :b] }
        @lathe.from( :a, :b )
        @event.origins.should == [:a, :b]
        @event.targets.should == nil
      end
      it "should ... on successive invocations"
    end

    describe ".to" do
      it "should create any states mentioned which do not exist and add them to machine.states"
      it "should ... on successive invocations"
    end

    describe ".requires()" do

      before do
        @event.requirements.should == []
      end

      it "should add :method_name to event.requirements given a name" do
        @lathe.requires( :method_name )
        @event.requirements.should == [:method_name]
      end

      it "should add to machine.named_procs if a block is given" do
        class << @machine
          attr_accessor :named_procs
        end
        @machine.named_procs = {}
        block = lambda { puts "wee" }
        @machine.named_procs.should == {}
        @lathe.requires( :method_name, &block )
        @event.requirements.should == [:method_name]
        @machine.named_procs[:method_name].should == block
      end

    end  # requires

  end # ?
end

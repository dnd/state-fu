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
        @lathe.state( :wibble )
        @machine.states.should_not be_empty
        @machine.states.length.should == 1
        s = @machine.states.first
        @lathe.state( :wibble, { :meta => :voodoo } ).should == s
        s.options[:meta].should == :voodoo
      end

    end # .state

    describe "defining a event with .event" do

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
      end

    end # .event

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

    describe "link" do

    end

    #describe "needs" do
    #  it "..."
    #end

    #describe "cycle" do
    #  it "..."
    #end

    describe "defining a state with .states" do
      it "should add all states named to the machine if they dont exist"
      it "should modify ..."
    end

    describe "all_states" do
      it "..."
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
      it "should create a named event from and to the lathe's sprocket (state)" do
        @machine = StateFu::Machine.new( :snoo )
        @master  = StateFu::Lathe.new( @machine )
        @state   = @master.state(:a)
        @lathe   = StateFu::Lathe.new( @machine, @state )

        @machine.events.should be_empty
        @machine.states.length.should == 1
        @lathe.cycle(:rebirth)
        @machine.events.should_not be_empty
        @machine.states.length.should == 1
        cycle = @machine.events.first
        cycle.should be_kind_of( StateFu::Event )
        cycle.origin.should == [@state]
        cycle.target.should == [@state]
      end

      it "should create an event with a default name if given no name"

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
    end

    describe "from" do
      it "should create any states mentioned which do not exist and add them to machine.states"
    end

    describe "to" do
      it "should create any states mentioned which do not exist and add them to machine.states"
    end

  end

end

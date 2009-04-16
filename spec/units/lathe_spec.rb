require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::Lathe do
  include MySpecHelper

  before do
    reset!
    make_pristine_class('Klass')
    @machine = Object.new()
    @state   = Object.new()
    @event   = Object.new()
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
      @lathe = StateFu::Lathe.new( @machine )
      @states = [].extend StateFu::StateArray
      stub( @machine ).states() { @states }
      @events = [].extend StateFu::EventArray
      stub( @machine ).events() { @events }
    end

    it "should be master?" do
      @lathe.should be_master
      @lathe.should_not be_child
    end

    describe "helper"

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

      describe "helper" do
        it "should call machine.helper *args" do
          mock( @machine ).helper( :fee, :fi, :fo, :fum )
          @lathe.helper( :fee, :fi, :fo, :fum )
        end
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

    end
  end # master lathe instance

  describe "a child lathe for a state" do
    before do
    end
  end

  describe "a child lathe for an event" do
    before do
    end
  end

end

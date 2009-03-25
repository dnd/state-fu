require File.expand_path("#{File.dirname(__FILE__)}/../helper")

## See state_and_event_common_spec.rb for behaviour shared between
## StateFu::State and StateFu::Event
##

describe StateFu::State do
  include MySpecHelper

  before do
    @machine = mock('StateFu::Machine')
  end

  describe "instance methods" do
    before do
      @state = StateFu::State.new(@machine, :flux, {:meta => "wibble"})
    end

    describe ".events" do

      it "should call machine.events.from(self)" do
        events = mock('Array')
        events.should_receive(:from).with(@state)
        @machine.should_receive(:events).and_return(events)
        @state.events
      end

    end

    describe ".event" do

      it "should act as a proxy for lathe.event without a block" do
        lathe = mock("StateFu::Lathe")
        @state.stub!( :lathe ).and_return( lathe )
        args = [:evt_name, {:from => :old, :to => :new}]
        lathe.should_receive(:event).with( *args )
        @state.event( *args )
      end

      it "should act as a proxy for lathe.event with a block" do
        lathe = mock("StateFu::Lathe")
        block  = lambda{}
        @state.stub!( :lathe ).and_return( lathe )
        args = [:evt_name, {:from => :old, :to => :new}]
        lathe.should_receive(:event).with( *args )
        @state.event( *args ){ puts "TODO: can't find a way to test the block is passed" }
      end

    end
  end
end

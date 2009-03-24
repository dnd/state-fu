require File.expand_path("#{File.dirname(__FILE__)}/../helper")

## See state_and_event_common_spec.rb for behaviour shared between
## Zen::State and Zen::Event
##

describe Zen::State do
  include MySpecHelper

  before do
    @koan = mock('Zen::Koan')
  end

  describe "instance methods" do
    before do
      @state = Zen::State.new(@koan, :flux, {:meta => "wibble"})
    end

    describe ".events" do

      it "should call koan.events.from(self)" do
        events = mock('Array')
        events.should_receive(:from).with(@state)
        @koan.should_receive(:events).and_return(events)
        @state.events
      end

    end

    describe ".event" do

      it "should act as a proxy for reader.event without a block" do
        reader = mock("Zen::Reader")
        @state.stub!( :reader ).and_return( reader )
        args = [:evt_name, {:from => :old, :to => :new}]
        reader.should_receive(:event).with( *args )
        @state.event( *args )
      end

      it "should act as a proxy for reader.event with a block" do
        reader = mock("Zen::Reader")
        block  = lambda{}
        @state.stub!( :reader ).and_return( reader )
        args = [:evt_name, {:from => :old, :to => :new}]
        reader.should_receive(:event).with( *args )
        @state.event( *args ){ puts "TODO: can't find a way to test the block is passed" }
      end

    end
  end
end

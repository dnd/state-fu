require File.expand_path("#{File.dirname(__FILE__)}/../helper")

## See state_and_event_common_spec.rb for behaviour shared between
## StateFu::State and StateFu::Event
##

describe StateFu::State do
  include MySpecHelper

  before do
    @machine = Object.new
  end

  describe "instance methods" do
    before do
      @state = StateFu::State.new( @machine, :flux, {:meta => "wibble"} )
    end

    describe ".events" do

      it "should call machine.events.from(self)" do
        machine_events = Object.new
        mock( @machine ).events { machine_events }
        mock( machine_events ).from( @state ) { nil }
        @state.events
      end

    end

    describe ".event" do

      it "should act as a proxy for lathe.event without a block" do
        lathe = Object.new
        mock( @state ).lathe { lathe }
        mock( lathe ).event( :evt_name, :from => :old, :to => :new ) { nil }
        @state.event( :evt_name, :from => :old, :to => :new )
      end

      it "should act as a proxy for lathe.event with a block" do
        lathe = Object.new
        block  = lambda{}
        stub( @state ).lathe { lathe }
        args = [:evt_name, {:from => :old, :to => :new}]
        mock( lathe ).event( *args ) {}
        @state.event( *args ){ puts "TODO: can't find a way to test the block is passed" }
      end

    end
  end
end

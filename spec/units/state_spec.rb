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
      @state    = Zen::State.new(@koan, :flux, {:meta => "wibble"})
    end

    describe ".event" do
      # => koan.define_event( name, options, &block )
      it "should piggyback on @koan.define_event()" do
        event    = mock("Zen::Event", :name => :existing)
        origin   = mock("Zen::Event", :name => :original)
        target   = mock("Zen::Event", :name => :improved)
        proc     = Proc.new{}
        options  = { :meta => "snoo", :to => target.name }
        state    = Zen::State.new( @koan, :flux )
        # reader   = mock("Zen::Reader")
        # reader.should_receive(:from).with( state )
        # reader.should_receive(:to).with( :potato )
        @koan.should_receive(:events).at_least(:once).
          and_return([].extend( Zen::EventArray ))
        @koan.should_receive(:find_or_create_states_by_name).with([:flux]).once.
          and_return([state])
        @koan.should_receive(:find_or_create_states_by_name).with([target.name]).once.
          and_return([target])
        state.event( origin.name, options, &proc )
        pending
      end
    end
  end

end

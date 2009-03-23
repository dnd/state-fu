require File.expand_path("#{File.dirname(__FILE__)}/../helper")

## See state_and_event_common_spec.rb for behaviour shared between
## Zen::State and Zen::Event
##

describe Zen::State do
  include MySpecHelper

  before do
    @koan = mock('Koan')
  end

  describe "instance methods" do

    before do
      @state    = Zen::State.new(@koan, :flux, {:meta => "wibble"})
    end

    describe ".event" do
      # => koan.define_event( name, options, &block )
      it "should piggyback on @koan.define_event()" do
        evt_name = :bubble
        proc     = Proc.new(){}
        options  = {:meta => "snoo", :to => :potato }
        state    = Zen::State.new(@koan, :flux)
        event    = mock("Event")
        event.should_receive(:from).with( state )
        event.should_receive(:to).with( :potato )
        @koan.should_receive(:define_event).
          with( evt_name, options , &proc ).
          once.
          and_return( event )
        state.event( evt_name, options, &proc )
      end
    end
  end

end

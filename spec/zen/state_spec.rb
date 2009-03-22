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
        options  = {:meta => "snoo" }
        event    = mock("Event")
        @koan.should_receive(:define_event).
          with( evt_name, options , &proc ).
          once.
          and_return( event )
        state    = Zen::State.new(@koan, :flux)
        state.event( evt_name, options, &proc )
      end
    end
  end

end

require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe Zen::State do
  include MySpecHelper

  describe "When there is an empty koan" do
    before do
      reset!
      make_pristine_class 'Klass'
      @koan = Klass.koan() { }
    end

    describe "calling Zen::State.new" do
      describe "when no block is supplied" do
        it "should create a new Zen::State given valid args" do
          state = Zen::State.new(@koan, :flux)
          state.should be_kind_of( Zen::State )
          state.name.should == :flux
          state.options.should == {}
          state.koan.should == @koan
        end
      end
      describe "passing a block" do
        it "should create a new Zen::State given valid args" do
          state = Zen::State.new(@koan, :flux) { }
          state.should be_kind_of( Zen::State )
          state.name.should == :flux
          state.options.should == {}
          state.koan.should == @koan
        end

        it "should yield itself if the block's arity is 1" do
          yielded = false
          state   = Zen::State.new(@koan, :flux){ |s| yielded = s  }
          yielded.should == state
        end

        it "should instance_eval the block if its arity is 0/-1" do
          yielded = false
          state   = Zen::State.new(@koan, :flux){ yielded = self }
          yielded.should == state
        end
      end
    end

    describe "instance methods" do

      describe "event" do
        # => koan.define_event( name, options, &block )
        it "should piggyback on @koan.define_event()" do
          pending "look @ rspec mocks / stubs - no rr here"
        end
      end

      describe "update!" do
        it "should merge any options passed into .options"
        it "should instance_eval the block if one is passed"
        it "should return itself"
      end
    end
  end
end

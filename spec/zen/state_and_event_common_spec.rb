require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Common functionality shared between Zen::State & Zen::Event" do

  include MySpecHelper

  before do
    class Klass
      include Zen::Interfaces::StateAndEvent
    end
    @koan = mock('Koan')
  end

  describe "calling Klass.new" do
    describe "when no block is supplied" do
      it "should create a new Klass given valid args" do
        state = Klass.new(@koan, :flux)
        state.should be_kind_of( Klass )
        state.name.should == :flux
        state.options.should == {}
        state.koan.should == @koan
      end
    end
    describe "passing a block" do
      it "should create a new Klass given valid args" do
        state = Klass.new(@koan, :flux) { }
        state.should be_kind_of( Klass )
        state.name.should == :flux
        state.options.should == {}
        state.koan.should == @koan
      end

      it "should yield itself if the block's arity is 1" do
        yielded = false
        state   = Klass.new(@koan, :flux){ |s| yielded = s  }
        yielded.should == state
      end

      it "should instance_eval the block if its arity is 0/-1" do
        yielded = false
        state   = Klass.new(@koan, :flux){ yielded = self }
        yielded.should == state
      end
    end
  end

  describe "instance methods" do
    before do
      @klass    = Klass.new(@koan, :flux, {:meta => "wibble"})
    end

    describe "update!" do
      it "should merge any options passed into .options" do
        opts    = @klass.options
        newopts =  { :size => "huge", :colour => "orange" }
        @klass.update!( newopts )
        @klass.options.should == opts.merge(newopts)
      end

      it "should instance_eval the block if one is passed" do
        ref = nil
        @klass.update!(){ ref = self }
        ref.should == @klass
      end

      it "should return itself" do
        @klass.update!.should == @klass
      end
    end

    describe "to_sym" do
      it "should return its name" do
        @klass.to_sym.should == @klass.name
      end
    end

  end
end

require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Common features / functionality for StateFu::State & StateFu::Event" do

  include MySpecHelper
  Phrase = StateFu::Phrase
  before do
    @machine = mock('Machine')
  end

  describe "calling Phrase.new" do
    it "should create a new Phrase given valid args" do
      phrase = Phrase.new(@machine, :flux, { :meta => :doodle })
      phrase.should be_kind_of( Phrase )
      phrase.name.should == :flux
      phrase.options[:meta].should == :doodle
      phrase.machine.should == @machine
    end
  end

  describe "instance methods" do
    before do
      @phrase = Phrase.new(@machine, :flux, {:meta => "wibble"})
    end

    describe ".apply!" do

      it "should yield itself if the block's arity is 1" do
        yielded = false
        @phrase.apply!{ |s| yielded = s  }
        yielded.should == @phrase
      end

      it "should instance_eval the block if its arity is 0/-1" do
        yielded = false
        @phrase.apply!{ yielded = self }
        yielded.should == @phrase
      end
    end

    describe "update!" do
      it "should merge any options passed into .options" do
        opts    = @phrase.options
        newopts =  { :size => "huge", :colour => "orange" }
        @phrase.update!( newopts )
        @phrase.options.should == opts.merge(newopts)
      end

      it "should instance_eval the block if one is passed" do
        ref = nil
        @phrase.update!(){ ref = self }
        ref.should == @phrase
      end

      it "should return itself" do
        @phrase.update!.should == @phrase
      end
    end

    describe "to_sym" do
      it "should return its name" do
        @phrase.to_sym.should == @phrase.name
      end
    end

  end
end

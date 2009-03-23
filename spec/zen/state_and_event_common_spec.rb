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
    it "should create a new Klass given valid args" do
      klass = Klass.new(@koan, :flux, { :meta => :doodle })
      klass.should be_kind_of( Klass )
      klass.name.should == :flux
      klass.options[:meta].should == :doodle
      klass.koan.should == @koan
    end
  end

  describe "instance methods" do
    before do
      @klass = Klass.new(@koan, :flux, {:meta => "wibble"})
    end

    describe ".apply!" do

      it "should yield itself if the block's arity is 1" do
        yielded = false
        @klass.apply!{ |s| yielded = s  }
        yielded.should == @klass
      end

      it "should instance_eval the block if its arity is 0/-1" do
        yielded = false
        @klass.apply!{ yielded = self }
        yielded.should == @klass
      end
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

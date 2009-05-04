require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Copying / cloning a Machine" do

  include MySpecHelper

  describe "a shallow copy" do
    before do
      reset!
      make_pristine_class("Klass")
      @original = Klass.machine do
        state :a do
          event :goto_b, :to => :b
        end
      end
      @copy = @original.clone
    end

    it "should update a state or event in the original when it's changed in the copy" do
      @original.events[:goto_b].should == @copy.events[:goto_b]
      @copy.lathe do
        event( :goto_b, :wibble => :updated ) do
          to :bee
        end
        state( :b, :picture => "Bee" ) do
        end
      end
      @copy.    events[:goto_b].options[:wibble].should == :updated
      @original.events[:goto_b].options[:wibble].should == :updated
      @copy.    states[:b].options[:picture].should == 'Bee'
      @original.states[:b].options[:picture].should == 'Bee'
    end

    it "should update the original with any changes to helpers"
    it "should update the original with any changes to named_procs"
    it "should update the original with any changes to requirement_messages"

  end # shallow

  describe "a deep copy" do
    before do
      reset!
      make_pristine_class("Klass")
      @original = Klass.machine do
        state :a do
          event :goto_b, :to => :b
        end
      end
      @copy = @original.deep_copy()
    end

    it "should NOT update a state or event in the original when it's changed in the copy" do
      @copy.states.map(&:name).should == @original.states.map(&:name)
      @copy.events.map(&:name).should == @original.events.map(&:name)

      @copy.lathe do
        event( :goto_b, :wibble => :updated ) do
          to :bee
        end
        state( :b, :picture => "Bee" ) do
        end
      end
      @copy.    events[:goto_b].options[:wibble].should == :updated
      @original.events[:goto_b].options[:wibble].should == nil
      @copy.    states[:b].options[:picture].should == 'Bee'
      @original.states[:b].options[:picture].should == nil
    end

    it "should NOT update the original with any changes to helpers"
    it "should NOT update the original with any changes to named_procs"
    it "should NOT update the original with any changes to requirement_messages"

  end # deep

end

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

    it "should update any event in the original when it's changed in the copy" do
      @original.events[:goto_b].should == @copy.events[:goto_b]
      @copy.lathe do
        event :goto_b do |e|
          e.options[:wibble] = :updated
        end
      end
      @copy.    events[:goto_b].options[:wibble].should == :updated
      @original.events[:goto_b].options[:wibble].should == :updated
    end

    it "should update any state in the original when it's changed in the copy" do
      @original.states[:a].should == @copy.states[:a]
      @copy.lathe do
        state :a do |s|
          s.options[:wibble] = :updated
        end
      end
      @copy.    states[:a].options[:wibble].should == :updated
      @original.states[:a].options[:wibble].should == :updated
    end

    it "should update the original with any changes to options"
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
      @copy = @original.deep_clone
    end

    it "should NOT update any event in the original when it's changed in the copy" do
      @original.events[:goto_b].should == @copy.events[:goto_b]
      @copy.lathe do
        event :goto_b do |e|
          e.options[:wibble] = :updated
        end
      end
      @copy.    events[:goto_b].options[:wibble].should == :updated
      @original.events[:goto_b].options[:wibble].should == nil
    end

    it "should NOT update any state in the original when it's changed in the copy" do
      @original.states[:a].should == @copy.states[:a]
      @copy.lathe do
        state :a do |s|
          s.options[:wibble] = :updated
        end
      end
      @copy.    states[:a].options[:wibble].should == :updated
      @original.states[:a].options[:wibble].should == nil
    end

    it "should NOT update the original with any changes to options"
    it "should NOT update the original with any changes to helpers"
    it "should NOT update the original with any changes to named_procs"
    it "should NOT update the original with any changes to requirement_messages"

  end # deep

end

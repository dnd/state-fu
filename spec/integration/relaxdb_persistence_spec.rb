require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "a RelaxDB::Document with StateFu included:" do

  include MySpecHelper

  before(:each) do
    reset!
    prepare_relaxdb()
    make_pristine_class( 'ExampleDoc', RelaxDB::Document )
    # end class ExampleRecord
  end

  it "should be a subclass of RelaxDB::Document" do
    ExampleDoc.superclass.should == RelaxDB::Document
  end

  describe "when no machine is defined" do
  end

  describe "when the :field_name is a RelaxDB property" do
    before do
      ExampleDoc.class_eval do
        property :property_field
        machine :field_name => "property_field" do
          # ...
        end
      end
      @obj = ExampleDoc.new
    end

    it "should add a relaxdb persister" do
      @obj.state_fu.persister.class.should == StateFu::Persistence::RelaxDB
    end

  end

  describe "when the :field_name is not a RelaxDB property" do
    before do
      ExampleDoc.class_eval do
        machine :field_name => "not_a_property" do
          # ...
        end
      end
      @obj = ExampleDoc.new
    end
    it "should add an attribute-based persister" do
      @obj.state_fu.persister.class.should == StateFu::Persistence::Attribute
    end
  end

  describe "when the default machine is defined" do
  end
end

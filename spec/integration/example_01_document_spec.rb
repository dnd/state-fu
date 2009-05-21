require File.expand_path("#{File.dirname(__FILE__)}/../helper")

# require 'activesupport' 
# require 'activerecord'

describe "Document" do
  include MySpecHelper
  before do
    reset!
    prepare_active_record do
      def self.up
        create_table :documents do |t|
          t.string :name
          t.string :author
          t.string :status_field
        end
      end
    end
    make_pristine_class('Document', ActiveRecord::Base )
    Document.class_eval do
      include StateFu

      attr_accessor :author

      def update_rss
        # puts "new feed!"
      end

      machine( :status ) do
        state :draft do
          event :publish, :to => :published
        end

        state :published do
          on_entry :update_rss
          requires :author
        end

        event :delete, :from => :ALL, :to => :deleted do
          execute :destroy
        end

        events do
          after :save!
        end
      end
    end

    @doc = Document.new
    # @doc.status
    end

  describe "a new document with no attributes" do

    it "should have a status.name of :draft" do
      @doc.status.name.should == :draft
    end

    it "should have no author" do
      @doc.author.should be_nil
    end

    it "should raise a RequirementError when publish! is called" do
      lambda { @doc.status.publish! }.should raise_error( StateFu::RequirementError )
      begin
        @doc.status.publish!
      rescue StateFu::RequirementError => e
        e.message.should =~ /[:author]/
      end
    end
  end

  describe "a new document with an author" do
    before do
      @doc.author = "Susan"
    end

    it "should have a status.name of :draft" do
      @doc.status.name.should == :draft
    end

    it "should have an author" do
      @doc.author.should_not be_nil
    end

    it "should not raise an error when publish! is called" do
      @doc.status.evaluate_requirement(:author).should == "Susan"
      lambda { @doc.status.publish! }.should_not raise_error( )
    end

    it "should call update_rss when publish! is called" do
      mock( @doc ).update_rss() {}
      @doc.status.publish!
    end

    it "should have the state name :published after .publish! is called" do
      @doc.status.publish!
      @doc.status.current_state_name.should == :published
    end

    describe "status_field attribute" do
      it "should be private in ruby 1.8 and 1.9"

      it "should be defined before state_fu is called" do
        @doc.send( :status_field ).should == 'draft'
      end

      it "should have an initial value of 'draft'" do
        @doc.instance_eval { status_field }.should == "draft"
      end

      it "should be set to 'published' after publish! is called successfully" do
        @doc.status.publish!
        @doc.instance_eval { status_field }.should == "published"
      end
    end  # status_field
  end # with author

  describe "delete!" do

    it "should execute destroy()" do
      mock( @doc ).destroy() {}
      @doc.status.delete!
    end

  end

end

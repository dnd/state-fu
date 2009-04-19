require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "Document" do
  before do

    class Document
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
      end
    end

  end

  describe "a new document with no attributes" do
    before do
      @doc = Document.new
      @doc.status
    end

    it "should have a status.name of :draft" do
      @doc.status.name.should == :draft
    end

    it "should have an attribute .status_field set to 'draft'"

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
      @doc = Document.new
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

    it "should call update_rss when publish! is called"
    it "should have the state name :published after .publish! is called"
    it "should have the attribute .status_field set to 'publish' after publish! is called"
  end
end

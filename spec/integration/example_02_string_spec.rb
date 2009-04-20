require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe String do
  include MySpecHelper
  before do
    reset!
    String.class_eval do
      include StateFu

      def sanitize_for_shell!
        gsub!(/([\\\t\| &`<>)('"])/) { |s| '\\' << s }
      end

      def dirty?
        shell.name == :dodgy
      end

      def clean?
        shell.name == :ok
      end


      #def escape
      #  klone = clone
      #end

      machine (:shell) do
        event(:escape, :from => {:dodgy => :ok}) do
          execute :sanitize_for_shell!
        end
      end
    end # String
    @str = "; nohup 'rm -rf /opt' &"
  end # before

  it "should initially be dirty" do
    @str.dirty?.should be_true
  end

  it "should call sanitize_for_shell! when shell.escape! is called, and be clean afterwards " do
    @str.should be_dirty
    @str.should_not be_clean
    mock( @str ).sanitize_for_shell! {}
    @str.shell.escape!
    @str.should_not be_dirty
    @str.should be_clean
  end

  it "should raise an InvalidTransition if shell.escape! is called more than once" do
    @str.shell.escape!
    @str.shell.state_name.should == :ok

    lambda { @str.shell.escape! }.should raise_error( StateFu::InvalidTransition )
  end

  it "should modify the string when shell.escape is called" do
    original             = @str.dup
    original.should     == @str
    @str.shell.escape!
    original.should_not == @str
  end


end

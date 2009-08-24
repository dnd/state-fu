require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe StateFu::Plotter do
  include MySpecHelper
  before do
    reset!
    make_pristine_class('Klass')
    @machine = Klass.state_fu_machine(:drawme) do
      chain 'clean -tarnish-> dirty -fester-> putrid'
    end
    @machine = Klass.state_fu_machine(:drawme)
  end


  describe "class methods" do
    describe ".new" do
      it "should expect a StateFu::Machine and return a Plotter" do
        @plotter = StateFu::Plotter.new( @machine )
        @plotter.should be_kind_of(StateFu::Plotter)
        @plotter.machine.should == @machine
        lambda { StateFu::Plotter.new( "abracadabra" ) }.should raise_error(RuntimeError)
      end
    end

    describe "a new plotter" do
      before do
        @plotter = StateFu::Plotter.new( @machine )
      end

      it "should have an empty hash of states" do
        @plotter = StateFu::Plotter.new( @machine )
        @plotter.states.should == {}
      end

    end
  end # class methods

  describe "instance methods" do
    before do
      @plotter = StateFu::Plotter.new( @machine )
    end

    describe ".generate" do

      it "should call generate_dot!" do
        mock( @plotter ).generate_dot!() { "dot" }
        @plotter.generate
      end

      it "should store the result in the dot attribute" do
        mock( @plotter).generate_dot!() { "dot" }
        @plotter.generate
        @plotter.dot.should == "dot"
      end

      describe ".save_as(filename)" do
        it "should save the string to a file" do
          mock( File).open( 'filename', 'w' ).yields( @fh = Object.new() )
          mock( @fh ).write( @plotter.output )
          @plotter.output.save_as( 'filename' )
        end
      end

      describe ".save!" do
        it "should save the string in a tempfile and return the path" do
          mock(@tempfile = Object.new).path {"path"}.subject
          mock(Tempfile).new(['state_fu_graph','.dot']).yields( @fh = Object.new() ) { @tempfile }
          mock( @fh ).write( @plotter.output )
          @plotter.output.save!.should == 'path'
        end
      end
    end # instance methods

    describe "output" do
      it "should return the result of .generate" do
        @plotter.output.should == @plotter.generate
      end
    end

    describe "generate_dot!" do
      it "should return a string" do
        @plotter.generate_dot!.should be_kind_of(String)
      end

      it "should extend the string to respond_to save_as" do
        @plotter.output.should respond_to(:save_as)
      end
    end # output

  end
end



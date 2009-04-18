require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding events to a Machine outside a state block" do

  include MySpecHelper

  describe "When there is an empty machine" do
    before do
      reset!
      make_pristine_class 'Klass'
      Klass.machine() { }
    end

    describe "calling Klass.machine().events" do
      it "should return []" do
        Klass.machine().events.should == []
      end
    end

    describe "calling event(:die){ from :dead, :to => :alive } in a Klass.machine()" do
      before do
        Klass.machine do
          event :die do # arity == 0
            from :dead, :to => :alive
          end
        end
      end

      it "should require a name when calling machine.event()" do
        lambda { Klass.machine(){ event {} } }.should raise_error(ArgumentError)
      end

      it "should add 2 states to the machine called: [:dead, :alive] " do
        Klass.machine.state_names.should == [:dead, :alive]
        Klass.machine.states.length.should == 2
        Klass.machine.states.each { |s| s.should be_kind_of(StateFu::State) }
        Klass.machine.states.map(&:name).sort.should == [:alive, :dead]
      end

      describe "the <StateFu::Event> created" do
        it "should be accessible through Klass.machine.events" do
          Klass.machine.events.should be_kind_of(Array)
          Klass.machine.events.length.should == 1
          Klass.machine.events.first.should be_kind_of( StateFu::Event )
          Klass.machine.events.first.name.should == :die
        end
      end

    end

    # arity of blocks is optional, thanks to magic fairy dust ;)
    describe "calling event(:die){ |s| s.from :dead, :to => :alive } in a Klass.machine()" do
      before do
        Klass.machine do
          event :die do |s|
            s.from :dead, :to => :alive
          end
        end
      end

      it "should add 2 states to the machine called [:dead, :alive] " do
        Klass.machine.state_names.should == [:dead, :alive]
        Klass.machine.states.length.should == 2
        Klass.machine.states.each { |s| s.should be_kind_of( StateFu::State ) }
      end
    end

  end
end


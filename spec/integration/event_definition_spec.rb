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

# it "should have the target_state_names [:dead]" do
#   e = Klass.machine.events.first
#   e.should respond_to(:target_names)
#   e.target_names.should == [:dead]
# end
#
# it "should have the origin_state_names [:alive]" do
#   e = Klass.machine.events.first
#   e.should respond_to(:origin_names)
#   e.origin_names.should == [:alive]
# end
#
# it "should be simple? because it has only one target and origin" do
#   e = Klass.machine.events.first
#   e.should respond_to(:simple?)
#   e.should be_simple
# end
#
# it "should have the target_state_name :dead" do
#   e = Klass.machine.events.first
#   e.should respond_to(:target_name)
#   e.target_name.should == :dead
# end
#
# it "should have the origin_state_name :alive" do
#   e = Klass.machine.events.first
#   e.should respond_to(:target_state_name)
#   e.origin_state_name.should == :alive
# end
#
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


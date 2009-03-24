require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe "Adding events to a Koan outside a state block" do

  include MySpecHelper

  describe "When there is an empty koan" do
    before do
      reset!
      make_pristine_class 'Klass'
      Klass.koan() { }
    end

    describe "calling Klass.koan().events" do
      it "should return []" do
        Klass.koan().events.should == []
      end
    end

    describe "calling event(:die){ from :dead, :to => :alive } in a Klass.koan()" do
      before do
        Klass.koan do
          event :die do # arity == 0
            from :dead, :to => :alive
          end
        end
      end

      it "should require a name when calling koan.event()" do
        lambda { Klass.koan(){ event {} } }.should raise_error(ArgumentError)
      end

      it "should add 2 states to the koan called: [:dead, :alive] " do
        Klass.koan.state_names.should == [:dead, :alive]
        Klass.koan.states.length.should == 2
        Klass.koan.states.each { |s| s.should be_kind_of(Zen::State) }
        Klass.koan.states.map(&:name).sort.should == [:alive, :dead]
      end

      describe "the <Zen::Event> created" do
        it "should be accessible through Klass.koan.events" do
          Klass.koan.events.should be_kind_of(Array)
          Klass.koan.events.length.should == 1
          Klass.koan.events.first.should be_kind_of( Zen::Event )
          Klass.koan.events.first.name.should == :die
        end

# it "should have the target_state_names [:dead]" do
#   e = Klass.koan.events.first
#   e.should respond_to(:target_names)
#   e.target_names.should == [:dead]
# end
#
# it "should have the origin_state_names [:alive]" do
#   e = Klass.koan.events.first
#   e.should respond_to(:origin_names)
#   e.origin_names.should == [:alive]
# end
#
# it "should be simple? because it has only one target and origin" do
#   e = Klass.koan.events.first
#   e.should respond_to(:simple?)
#   e.should be_simple
# end
#
# it "should have the target_state_name :dead" do
#   e = Klass.koan.events.first
#   e.should respond_to(:target_name)
#   e.target_name.should == :dead
# end
#
# it "should have the origin_state_name :alive" do
#   e = Klass.koan.events.first
#   e.should respond_to(:target_state_name)
#   e.origin_state_name.should == :alive
# end
#
      end
    end

    # arity of blocks is optional, thanks to magic fairy dust ;)
    describe "calling event(:die){ |s| s.from :dead, :to => :alive } in a Klass.koan()" do
      before do
        Klass.koan do
          event :die do |s|
            s.from :dead, :to => :alive
          end
        end
      end

      it "should add 2 states to the koan called [:dead, :alive] " do
        Klass.koan.state_names.should == [:dead, :alive]
        Klass.koan.states.length.should == 2
        Klass.koan.states.each { |s| s.should be_kind_of( Zen::State ) }
      end
    end

  end
end


require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe "being sane" do
  before do
    make_pristine_class('Klass')
    Klass.class_eval do
      attr_accessor :ok, :calls
      
      def called *args
        @calls ||= []
        @calls << args.map{|a| a.is_a?(Symbol) ? a : a.class }
        #puts a.inspect
      end

      def klass_method *args
        called :klass_method, *args
        # called :klass_method_self, self
        #called :klass_method_current_transition, current_transition
        # called :klass_method_context, ctx
      end

      def klass_requirement? tr, *args
        called :klass_requirement?, tr, *args
        # called :klass_requirement_self, self
        @ok
      end
    end

    Klass.machine do
      state :a do
        event :go, :to => :b do
          requires :klass_requirement?
          execute :klass_method
        end
      end
    end

    @obj = Klass.new
  end

  it "!" do 
    @obj.ok = true
    @obj.state_fu.valid_transitions.should_not    == []
    @obj.state_fu.valid_transitions.length.should == 1
  end

  it "should be sane as butter" do
    @obj.ok = false
    @obj.state_fu.go?.should == false
    @obj.calls.length.should == 1
    @obj.calls.last.should == [:klass_requirement?,StateFu::Transition]
    @obj.state_fu.go?(:a,:b,:c).should == false
    @obj.calls.length.should == 2
    @obj.calls.last.should == [:klass_requirement?,StateFu::Transition, :a, :b, :c]
    
    @obj.ok = true    

    @obj.calls = nil
    
    @obj.state_fu.go?.should == true
    @obj.calls.length.should == 1
    @obj.calls.last.should == [:klass_requirement?,StateFu::Transition]
    @obj.state_fu.go?(:a,:b,:c).should == true
    @obj.calls.length.should == 2
    @obj.calls.last.should == [:klass_requirement?,StateFu::Transition, :a, :b, :c]

    @obj.calls = nil
    
    @obj.state_fu.next_transition(:x,:y).should be_kind_of(StateFu::Transition)
    @obj.calls.length.should == 1
    @obj.calls.last.should == [:klass_requirement?,StateFu::Transition, :x, :y]

    @obj.calls = nil    

    @obj.go!(:a,:b,:c)
    @obj.calls.length.should == 3
    @obj.calls.map(&:first).should == [:klass_requirement?, :klass_requirement?, :klass_method]
    @obj.calls.last.should == [:klass_method, :a, :b, :c]

    @obj.state_fu.current_state.should == :b
  end

end


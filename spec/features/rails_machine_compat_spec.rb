require File.expand_path("#{File.dirname(__FILE__)}/../helper")

module StateFu::Compatibility

  class StateFu::State 
    attr_accessor :sequence
  end

  module LatheTool
    def sequence
      valid_in_context(StateFu::Event)
      requires :origin_state_in_list?, :message => lambda { 
        "uh oh"
      }
    end      
  end

  module BindingHelper

    def origin_state_in_list?(t)    
      raise t.inspect  
      return true if t.event.sequence.empty?
      origin_list = event[target.to_sym].sequence 
      origin_list.include?(t.origin)
    end

    
    def next_in_sequence(state=current_state)
      next_in_sequence_from_state(state)
    end
        
    def next_in_sequence_from_state(seq, state)
      
    end
  end
  
  module InstanceMethods
    
    def current_state( binding_name = StateFu::DEFAULT )
      state_fu( binding_name ).current_state
    end          
    
  end

  def self.included( base )
    base.send :include, StateFu
    base.send :include, InstanceMethods
    base.class_eval do
      # alias_method :state_machine, :machine
    end
  end
end

describe "activemodel::state_machine syntax" do

  before do
    prepare_active_record do
      def self.up
        create_table :example_records do |t|
          t.string :name,           :null => false
          t.string :state_fu_field, :null => false
          t.string :description
          t.timestamps
        end
      end
    end # activerecord

    make_pristine_class( 'ExampleRecord', ActiveRecord::Base )

    ExampleRecord.class_eval do
      include StateFu::Compatibility

      state_machine do
        tool   StateFu::Compatibility::LatheTool
        helper StateFu::Compatibility::BindingHelper
        
        state :red
        state :green
        state :yellow

        event :change_color do

          # ew
          # sequence

          transitions :to => :red,    :from => [:yellow], :on_transition => :catch_runners
          transitions :to => :yellow, :from => [:green]
          transitions :to => :green,  :from => [:red]
        end
      end

      def catch_runners
        puts "That'll be $250."
      end
    end # class eval
    @machine = ExampleRecord.state_machine
    @obj     = ExampleRecord.new
  end # before

  describe "machine" do
    it "? " do
      m  = ExampleRecord.machine
      ex = ExampleRecord.new
      ex.stfu.events.should include(m.events[:change_color])
      m = ExampleRecord.machine
      ex.stfu.valid_next_states.should == [:green]
      ex.change_color!
      ex.stfu.should == :green
    end
    
    it "should have three events :red, :green, :yellow" do
      @machine.states.should == [:red, :green, :yellow]
    end

    it "should have one event :change_color" do
      @machine.events.should == [:change_color]
    end
    
    it "should have an execute hook for the state, :catch_runners" do
      @machine.states[:red].hooks.should == 
        {:exit => [], :entry => [], :accepted => [:catch_runners]}
    end
    
    it "should have " do
      @machine.events[:change_color].sequence.should == 
        {:red=>[:yellow], :yellow=>[:green], :green=>[:red]}
    end
  end

  describe "behaviour" do
    
    it "should return the current_state for the binding on #current_state" do
      @obj.current_state.should == @obj.state_fu.current_state
      @obj.current_state.should be_kind_of(StateFu::State)
      @obj.current_state.should == :red
    end
    
    it "should not be allowed to act out of turn" do
      # @obj.state_fu.change_color?(:red).should == false
      # @obj.state_fu.change_color?(:yellow).should == false
      # @obj.state_fu.change_color?(:green).should == true
      @obj.state_fu.next_transition.should be_kind_of(StateFu::Transition)
      @obj.current_state.should == :red
      @obj.state_fu.valid_next_states.names.should == [:green]
      @obj.state_fu.next_transition.should_not be_nil
      @obj.state_fu.change_color!
    end
    
    it "should transition on change_color!" do
      @obj.current_state.should == :red
      @obj.change_color!
      @obj.current_state.should == :green
    end

    it "should transition on change_color! given a target state name" do
      @obj.current_state.should == :red
      @obj.state_fu.fire! [:change_color, :green] 
      @obj.current_state.should == :green      
    end
    
  end

end

__END__

# light = TrafficLight.new
# light.current_state       #=> :red
# light.change_color!       #=> true
# light.current_state       #=> :green
# light.change_color!       #=> true
# light.current_state       #=> :yellow
# light.change_color!       #=> true
# "That'll be $250."

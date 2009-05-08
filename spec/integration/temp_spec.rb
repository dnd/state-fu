require File.expand_path("#{File.dirname(__FILE__)}/../helper")

describe StateFu::State do
  include MySpecHelper

  it "should respond to deep_copy" do
    reset!
    make_pristine_class "Klass"
    @machine = Klass.machine do
      state :initial
    end
    @state = @machine.states.first
    @state.should respond_to(:deep_copy)
  end

end


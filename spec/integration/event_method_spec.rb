require File.expand_path("#{File.dirname(__FILE__)}/../helper")
describe "methods defined on a stateful instance to fire events" do
  include MySpecHelper

  before(:each) do
    reset!
    make_pristine_class("Klass")
    Klass.machine do

      # cycle event
      state :tick do
        cycle(:cycle_tick)
      end

      # simple (single target / origin) event
      event(:simplify, :from => :origin, :to => :target )

      # complex (multiple target / origin) event
      event(:complexify, :from => [:origin_a, :origin_b], :to => [:target_a, :target_b] )

    end
  end

  describe "simple event trigger methods" do
    describe "on binding" do
      it "should define simplify! when lathe ..."
    end
  end
end

require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe StateFu::Event do
  include MySpecHelper
  before do
    @machine = mock('Machine')
  end

  describe "Instance methods" do
    before do
      @name         = :germinate
      @options      = {:speed => :slow}
      @event        = StateFu::Event.new( @machine, @name, @options )
      @state_a      = StateFu::State.new( @machine,:a )
      @state_b      = StateFu::State.new( @machine,:b )
      @initial      = mock('State:Initial')
      @final        = mock('State:Final')
      @start        = mock('State:Start')
      @end          = mock('State:End')
    end


    describe "Instance methods" do
      describe "setting origin / target" do

        describe 'origin=' do
          it "should call get_states_list_by_name with its argument"
          it "should set @origin to the result"
        end

        describe 'target=' do
          it "should ..."
        end

        describe "reader" do
          it "should return a StateFu::Reader"
          it "should have the event's machine"
          it "should have the event as the phrase"
          it "should eval ..."
        end

        describe '.from()' do
          describe "given @event.from :initial, :to => :final" do
            describe "setting attributes" do
              before do
                @machine.should_receive(:find_or_create_states_by_name).
                  with([:initial]).
                  once.
                  and_return([@initial])
                @machine.should_receive(:find_or_create_states_by_name).
                  with([:final]).
                  once.
                  and_return([@final])
              end

              it "should call @machine.find_or_create_states_by_name() with [:initial] and [:final]" do
                @event.from :initial, :to => :final
              end

              it "should set @event.origin to the returned array of origin states" do
                @event.from :initial, :to => :final
                @event.origin.should == [@initial]
              end

              it "should set @event.target to the returned array of target states" do
                @event.from :initial, :to => :final
                @event.target.should == [@final]
              end
            end

            it "should merge any options passed into event.options" do
              @machine.stub!(:find_or_create_states_by_name).and_return([])
              @event.from :initial, :to => :final, :colour => :green
              @event.options[:speed].should  == :slow
              @event.options[:colour].should == :green
            end
          end

          describe "given @event.from <Array>, :to => <Array>" do
            it "should call @machine.find_or_create_states_by_name() with both arrays" do
              @machine.should_receive(:find_or_create_states_by_name).
                with([:initial, :start]).
                once.
                and_return([@initial, @start])
              @machine.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.from( [:initial, :start], :to => [:final, :end] )
            end
          end
        end

        describe '.to()' do
          describe "given :final" do
            it "should set @event.target to [:final]" do
              @machine.should_receive(:find_or_create_states_by_name).
                with([:final]).
                once.
                and_return([@final])
              @event.to :final
              @event.target.should == [@final]
            end
          end

          describe "given [:final, :end]" do
            it "should set @event.target to [:final, :end]" do
              @machine.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.to( [:final, :end] )
              @event.target.should == [@final, @end]
            end
          end

          describe "given [:final], :end" do
            it "should set @event.target to [:final, :end]" do
              @machine.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.to( [:final], :end )
              @event.target.should == [@final, @end]
            end
          end
        end
      end

      describe 'origin_names' do
        it "should return an array of state names in origin when origin is not nil"
        it "should return nil when origin is nil"
      end

      describe 'target_names' do
        it "should return an array of state names in target when target is not nil"
        it "should return nil when target is nil"
      end

      describe 'to?' do
        it "should return true given a symbol which is the name of a state in @target" do
          @event.should_receive( :target ).
            at_least(:once).
            and_return( [StateFu::State.new(@machine,:a)] )
          @event.to?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @target" do
          @event.should_receive( :target ).
            at_least(:once).
            and_return( [StateFu::State.new(@machine,:a)] )
          @event.to?( :b ).should == false
        end

        it "should raise an exception when @target is a Proc" do
          @event.should_receive( :target ).
            at_least(:once).
            and_return( @proc_initial )
          lambda{  @event.to?( :b ) }.should raise_error()
        end
      end

      describe 'from?' do
        it "should return true given a symbol which is the name of a state in @origin" do
          @event.should_receive( :origin ).
            at_least(:once).
            and_return( [StateFu::State.new(@machine,:a)] )
          @event.from?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @origin" do
          @event.should_receive( :origin ).
            at_least(:once).
            and_return( [StateFu::State.new(@machine,:a)] )
          @event.from?( :b ).should == false
        end

        it "should raise an exception when @origin is a Proc" do
          @event.should_receive( :origin ).
            at_least(:once).
            and_return( @proc_initial )
          lambda{  @event.from?( :b ) }.should raise_error()
        end
      end

      describe 'complete?' do
        it "should be false if either origin / target are nil" do
          @event.complete?.should == false
        end

        it "should be true when origin / target are both not nil" do
          @event.should_receive( :origin ).and_return( [:a])
          @event.should_receive( :target ).and_return( [:b])
          @event.complete?.should == true
        end

        it "should be false when either origin / target are nil" do
          @event.should_receive( :origin ).and_return( [:a])
          # @event.should_receive( :target ).and_return( [:b])
          @event.complete?.should == false
        end

      end

    end # describe instance methods
  end   # describe StateFu::Event
end

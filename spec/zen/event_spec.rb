require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe Zen::Event do
  include MySpecHelper
  before do
    @koan = mock('Koan')
  end

  describe "Instance methods" do
    it("is") { pending "needing specs for all methods" }
    before do
      @name         = :germinate
      @options      = {:speed => :slow}
      @event        = Zen::Event.new( @koan, @name, @options )
      @state_a      = Zen::State.new( @koan,:a )
      @state_b      = Zen::State.new( @koan,:b )
      @proc_initial = Proc.new{}
      @proc_final   = Proc.new{}
      @initial      = mock('State:Initial')
      @final        = mock('State:Final')
      @start        = mock('State:Start')
      @end          = mock('State:End')
    end


    describe "Instance methods" do
      describe "setting origin / target" do

        describe 'origin=' do
          it "should ..."
        end

        describe 'target=' do
          it "should ..."
        end

        describe '.from()' do
          describe "given @event.from :initial, :to => :final" do
            describe "setting attributes" do
              before do
                @koan.should_receive(:find_or_create_states_by_name).
                  with([:initial]).
                  once.
                  and_return([@initial])
                @koan.should_receive(:find_or_create_states_by_name).
                  with([:final]).
                  once.
                  and_return([@final])
              end

              it "should call @koan.find_or_create_states_by_name() with [:initial] and [:final]" do
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
              @koan.stub!(:find_or_create_states_by_name).and_return([])
              @event.from :initial, :to => :final, :colour => :green
              @event.options[:speed].should  == :slow
              @event.options[:colour].should == :green
            end
          end

          describe "given @event.from <Array>, :to => <Array>" do
            it "should call @koan.find_or_create_states_by_name() with both arrays" do
              @koan.should_receive(:find_or_create_states_by_name).
                with([:initial, :start]).
                once.
                and_return([@initial, @start])
              @koan.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.from( [:initial, :start], :to => [:final, :end] )
            end
          end

          describe "given @event.from <Proc:initial>, :to => <Proc:final>" do
            it "should set @event.origin to <Proc:initial>" do
              @event.from @proc_initial, :to => @proc_final
              @event.origin.should == @proc_initial
            end

            it "should set @event.target to <Proc:final>" do
              @event.from @proc_initial, :to => @proc_final
              @event.target.should == @proc_final
            end
          end

        end

        describe '.to()' do
          describe "given :final" do
            it "should set @event.target to [:final]" do
              @koan.should_receive(:find_or_create_states_by_name).
                with([:final]).
                once.
                and_return([@final])
              @event.to :final
              @event.target.should == [@final]
            end
          end

          describe "given [:final, :end]" do
            it "should set @event.target to [:final, :end]" do
              @koan.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.to( [:final, :end] )
              @event.target.should == [@final, @end]
            end
          end

          describe "given [:final], :end" do
            it "should set @event.target to [:final, :end]" do
              @koan.should_receive(:find_or_create_states_by_name).
                with([:final, :end]).
                once.
                and_return([@final, @end])
              @event.to( [:final], :end )
              @event.target.should == [@final, @end]
            end
          end

          describe "given <Proc:final>" do
            it "should set @event.target to <Proc:final>" do
              @event.to @proc_final
              @event.target.should == @proc_final
            end
          end
        end
      end

      describe 'origin_names' do
        it "should return an array of state names in origin when static?(origin)" do
          @event.should_receive( :origin ).at_least(:once).and_return( [@state_a, @state_b] )
          @event.origin_names.should == [:a, :b ]
        end

        it "should return nil when dynamic?(origin)" do
          @event.should_receive( :origin ).at_least(:once).and_return( @proc_initial )
          @event.origin_names.should == nil
        end
      end

      describe 'target_names' do
        it "should return an array of state names in target when static?(target)" do
          @event.should_receive( :target ).at_least(:once).and_return( [@state_a, @state_b] )
          @event.target_names.should == [:a, :b ]
        end

        it "should return nil when dynamic?(target)" do
          @event.should_receive( :target ).at_least(:once).and_return( @proc_initial )
          @event.target_names.should == nil
        end
      end

      describe 'to?' do
        it "should return true given a symbol which is the name of a state in @target" do
          @event.should_receive( :target ).
            at_least(:once).
            and_return( [Zen::State.new(@koan,:a)] )
          @event.to?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @target" do
          @event.should_receive( :target ).
            at_least(:once).
            and_return( [Zen::State.new(@koan,:a)] )
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
            and_return( [Zen::State.new(@koan,:a)] )
          @event.from?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @origin" do
          @event.should_receive( :origin ).
            at_least(:once).
            and_return( [Zen::State.new(@koan,:a)] )
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
          @event.complete?.should          == false
        end

        it "should be true when origin / target are both not nil" do
          @event.should_receive( :origin ).and_return( [:a])
          @event.should_receive( :target ).and_return( [:b])
          @event.complete?.should == true
        end
      end

      describe 'static?' do

        it "should return nil when origin / target are unset" do
          @event.origin.should  == nil
          @event.target.should  == nil
          @event.static?.should == nil
          @event.static?(:origin).should == nil
          @event.static?(:target).should == nil
        end

        it "should return true when origin / target are not Procs" do
          @event.should_receive( :origin ).twice.and_return( [:a])
          @event.should_receive( :target ).twice.and_return( [:b])
          @event.static?.should == true
          @event.static?(:origin).should == true
          @event.static?(:target).should == true
        end

      end

      describe 'simple?' do
        it "should return nil when origin / target are unset" do
          @event.origin.should  == nil
          @event.target.should  == nil
          @event.simple?.should == nil
          @event.simple?(:origin).should == nil
          @event.simple?(:target).should == nil
        end

        it "should return false if either origin or target are a Proc and no arg supplied" do
          @event.should_receive( :origin ).at_least(:once).and_return( [@state_a] )
          @event.should_receive( :target ).at_least(:once).and_return( lambda{} )
          @event.simple?.should == false
          @event.simple?(:origin).should == true
          @event.simple?(:target).should == false
        end

        it "should return false when origin / target are Procs" do
          @event.should_receive( :origin ).at_least(:once).and_return( lambda{} )
          @event.should_receive( :target ).at_least(:once).and_return( lambda{} )
          @event.simple?.should == false
          @event.simple?(:origin).should == false
          @event.simple?(:target).should == false
        end

        it "should return true when origin / target are [<Zen::State>]" do
          @event.should_receive( :origin ).at_least(:once).and_return( [@state_a] )
          @event.should_receive( :target ).at_least(:once).and_return( [@state_b] )
          @event.simple?.should == true
          @event.simple?(:origin).should == true
          @event.simple?(:target).should == true
        end
      end

      describe 'dynamic?' do

        it "should return nil when origin / target are unset" do
          @event.origin.should   == nil
          @event.target.should   == nil
          @event.dynamic?.should == nil
          @event.dynamic?(:origin).should == nil
          @event.dynamic?(:target).should == nil
        end

        it "should return true if either origin or target are a Proc and no arg supplied" do
          @event.should_receive( :origin ).at_least(:once).and_return( [Zen::State.new(@koan,:a)] )
          @event.should_receive( :target ).at_least(:once).and_return( lambda{} )
          @event.dynamic?.should == true
          @event.dynamic?(:origin).should == false
          @event.dynamic?(:target).should == true
        end

        it "should return true when origin / target are Procs" do
          @event.should_receive( :origin ).at_least(:once).and_return( lambda{} )
          @event.should_receive( :target ).at_least(:once).and_return( lambda{} )
          @event.dynamic?.should == true
          @event.dynamic?(:origin).should == true
          @event.dynamic?(:target).should == true
        end

        it "should return false when origin / target are [<Zen::State>]" do
          @event.should_receive( :origin ).at_least(:once).and_return( [@state_a] )
          @event.should_receive( :target ).at_least(:once).and_return( [@state_b] )
          @event.dynamic?.should == false
          @event.dynamic?(:origin).should == false
          @event.dynamic?(:target).should == false
        end
      end
    end

  end
end

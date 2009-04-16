require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##

describe StateFu::Event do
  include MySpecHelper
  before do
    @machine = Object.new
  end

  describe "Instance methods" do
    before do
      @name         = :germinate
      @options      = {:speed => :slow}
      @event        = StateFu::Event.new( @machine, @name, @options )
      @state_a      = StateFu::State.new( @machine,:a )
      @state_b      = StateFu::State.new( @machine,:b )
      @initial      = Object.new
      @final        = Object.new
      @start        = Object.new
      @end          = Object.new
    end


    describe "Instance methods" do
      describe "setting origin / target" do

        describe "single_target?" do
          it "should be nil if the target is not" do
            stub( @event ).target() { nil }
            @event.single_target?.should == nil
          end

          it "should be false if the target has more than one state" do
            stub( @event ).target() { [@state_a, @state_b] }
            @event.single_target?.should == false
          end

          it "should be true if the target is set and there is only one" do
            stub( @event ).target() { [@state_a] }
            @event.single_target?.should == true
          end
        end

        describe 'origin=' do
          it "should call get_states_list_by_name with its argument" do
            mock( @machine ).find_or_create_states_by_name( [:initial] ) { }
            @event.origin= :initial
          end

          it "should set @origin to the result" do
            mock( @machine ).find_or_create_states_by_name( [:initial] ) { :result }
            @event.origin= :initial
            @event.origin.should == :result
          end

        end

        describe 'target=' do
          it "should call get_states_list_by_name with its argument" do
            mock( @machine ).find_or_create_states_by_name( [:initial] ) { }
            @event.target= :initial
          end

          it "should set @target to the result" do
            mock( @machine ).find_or_create_states_by_name( [:initial] ) { :result }
            @event.target= :initial
            @event.target.should == :result
          end
        end

        describe "lathe" do
          before do
            @lathe = @event.lathe()
          end

          it "should return a StateFu::Lathe" do
            @lathe.should be_kind_of( StateFu::Lathe )
          end

          it "should have the event's machine" do
            @lathe.machine.should == @event.machine()
          end

          it "should have the event as the sprocket" do
            @lathe.sprocket.should == @event
          end

        end

        describe '.from()' do
          describe "given @event.from :initial, :to => :final" do
            describe "setting attributes" do
              before do
                mock( @machine ).find_or_create_states_by_name( [:initial] ) { [@initial] }
                mock( @machine ).find_or_create_states_by_name( [:final]   ) { [@final]   }
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
              mock( @machine ).find_or_create_states_by_name([:initial]) { [@initial]}
              mock( @machine ).find_or_create_states_by_name([:final  ]) { [@final]}
              @event.from :initial, :to => :final, :colour => :green
              @event.options[:speed].should  == :slow
              @event.options[:colour].should == :green
            end
          end

          describe "given @event.from <Array>, :to => <Array>" do
            it "should call @machine.find_or_create_states_by_name() with both arrays" do
              mock( @machine ).find_or_create_states_by_name([:initial, :start]) do
                [@initial, @start]
              end
              mock( @machine ).find_or_create_states_by_name([:final, :end]) do
                [@final, @end]
              end
              @event.from( [:initial, :start], :to => [:final, :end] )
            end
          end
        end

        describe '.to()' do
          describe "given :final" do
            it "should set @event.target to machine.find_or_create_states_by_name( :final )" do
              mock( @machine ).find_or_create_states_by_name([:final]) { [@final] }
              @event.to :final
              @event.target.should == [@final]
            end
          end
        end

      end

      describe 'origin_names' do
        it "should return an array of state names in origin when origin is not nil" do
          mock( @machine ).find_or_create_states_by_name([:initial]) { [@initial] }
          mock( @machine ).find_or_create_states_by_name([:final]) { [@final] }
          @event.from :initial, :to => :final
          @event.origin.should == [@initial]
          mock( @initial ).to_sym().times(any_times) { :initial }
          @event.origin_names.should == [:initial]
        end

        it "should return nil when origin is nil" do
          mock( @event ).origin().times(any_times) { nil }
          @event.origin_names.should == nil
        end

      end

      describe 'target_names' do
        it "should return an array of state names in target when target is not nil" do
          mock( @event ).target.times( any_times ) { [@final] }
          mock( @final ).to_sym { :final }
          @event.target_names.should == [:final]
        end

        it "should return nil when target is nil" do
          mock( @event ).target().times(any_times) { nil }
          @event.target_names.should == nil
        end
      end

      describe 'to?' do
        it "should return true given a symbol which is the name of a state in @target" do
          mock( @event ).target.times(any_times) {  [StateFu::State.new(@machine,:a)] }
          @event.to?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @target" do
          mock( @event ).target.times(any_times) {  [StateFu::State.new(@machine,:a)] }
          @event.to?( :b ).should == false
        end
      end

      describe 'from?' do
        it "should return true given a symbol which is the name of a state in @origin" do
          mock( @event ).origin.times(any_times) {  [StateFu::State.new(@machine,:a)] }
          @event.from?( :a ).should == true
        end

        it "should return false given a symbol which is not the name of a state in @origin" do
          mock( @event ).origin().times(any_times) {  [StateFu::State.new(@machine,:a)] }
          @event.from?( :b ).should == false
        end
      end

      describe 'complete?' do
        it "should be false if either origin / target are nil" do
          @event.complete?.should == false
        end

        it "should be true when origin / target are both not nil" do
          mock( @event ).origin { [:a] }
          mock( @event ).target { [:b] }
          @event.complete?.should == true
        end

        it "should be false when either origin / target are nil" do
          mock( @event ).origin { [:a] }
          mock( @event ).target { nil  }
          @event.complete?.should == false
        end

      end

    end # describe instance methods
  end   # describe StateFu::Event
end

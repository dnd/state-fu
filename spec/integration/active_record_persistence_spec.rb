require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##
begin
  require 'active_record'

  class CreateTables < ActiveRecord::Migration
    def self.up
      create_table :example_records do |t|
        t.string :name,           :null => false
        t.text   :description
        t.string :state_fu_field, :null => false
        t.string :status
        t.timestamps
      end
    end

    def self.down
      raise ActiveRecord::IrreversibleMigration.new()
    end
  end

  describe "an ActiveRecord model with StateFu included:" do

    include MySpecHelper
    include NoStdout

    before(:each) do

      reset!
      # class ExampleRecord < ActiveRecord::Base
      make_pristine_class( 'ExampleRecord', ActiveRecord::Base )
      ExampleRecord.class_eval do
        validates_presence_of :name
      end
      # end class ExampleRecord


      @db_config = {
        :adapter  => 'sqlite3',
        :database => ':memory:'
      }
      ActiveRecord::Base.establish_connection( @db_config )
      no_stdout do
        CreateTables.migrate( :up )
      end
    end

    it "should be a subclass of ActiveRecord::Base" do
      ExampleRecord.superclass.should == ActiveRecord::Base
    end

    describe "when the default machine is defined with no field_name specified" do
      before do
        ExampleRecord.class_eval do
          machine do
            state :initial do
              event :change, :to => :final
            end
          end
        end
        @ex = ExampleRecord.new( :name => "exemplar" )
      end # before

      it "should not clobber activerecord accessors" do
        @ex.noodle! rescue nil
#        lambda { @ex.description }.should_not raise_error()
        @ex.description.should be_nil
        @ex.description= 'foo'
        @ex.description.should == 'foo'
      end

      it "should have an active_record string column 'state_fu_field' " do
        col = ExampleRecord.columns.detect {|c| c.name == "state_fu_field" }
        col.type.should == :string
      end

      describe "StateFu::Persistence.active_record_column?" do
        it "should return true for ExampleRecord, :state_fu_field" do
          StateFu::Persistence.active_record_column?( ExampleRecord, :state_fu_field ).should == true
        end

        it "should return true for ExampleRecord, :status" do
          StateFu::Persistence.active_record_column?( ExampleRecord, :status ).should == true
        end

        it "should return false for ExampleRecord, :not_a_column" do
          StateFu::Persistence.active_record_column?( ExampleRecord, :not_a_column ).should == false
        end
      end

      it "should have an active_record persister with the default field_name 'state_fu_field' " do
        @ex.state_fu
        @ex.state_fu.should be_kind_of( StateFu::Binding )
        @ex.state_fu.persister.should be_kind_of( StateFu::Persistence::ActiveRecord )
        @ex.state_fu.persister.field_name.should == :state_fu_field
      end


      # this ensures state_fu initializes the field before create to
      # satisfy the not null constraint
      describe "automagic state_fu! before_save filter and validations" do

        it "should call state_fu! before a record is created" do
          @ex.should be_new_record
          mock.proxy( @ex ).state_fu!.at_least( 1 ) { }
          @ex.save!
        end

        it "should call state_fu! before a record is updated" do
          @ex.should be_new_record
          mock.proxy( @ex ).state_fu!.at_least( 1 ) { }
          @ex.save!
        end

        it "should fail to save if state_fu! does not instantiate the binding before create" do
          pending "is this still relevant?"
          mock( @ex ).state_fu!.at_least( 1 ) { }
          lambda { @ex.save! }.should raise_error( ActiveRecord::StatementInvalid )
          @ex.state_fu_field.should == nil
        end

        it "should create a record given only a name, with the field set to the initial state" do
          ex = ExampleRecord.new( :name => "exemplar" )
          ex.should be_valid
          ex.state_fu_field.should == nil
          ex.save!
          ex.should_not be_new_record
          ex.state_fu_field.should == 'initial'
          ex.state_fu.state.name.should == :initial
        end

        it "should update the field after a transition is completed" do
          ex = ExampleRecord.create!( :name => "exemplar" )
          ex.state_fu.state.name.should == :initial
          ex.state_fu_field.should == 'initial'
          t =  ex.state_fu.fire!( :change )
          t.should be_accepted
          ex.state_fu.state.name.should == :final
          ex.state_fu_field.should == 'final'
          ex.attributes['state_fu_field'].should == 'final'
          ex.save!
        end

        describe "a saved record whose state is not the default" do
          before do
            @r = ExampleRecord.create!( :name => "exemplar" )
            @r.change!
            @r.state_fu_field.should == 'final'
            @r.save!
          end

          it "should be reconstituted with the correct state" do
            r = ExampleRecord.find( @r.id )
            r.state_fu.should be_kind_of( StateFu::Binding )
            r.state_fu.current_state.should be_kind_of( StateFu::State )
            r.state_fu.current_state.should == ExampleRecord.machine.states[:final]
          end
        end # saved record after transition

        describe "when a second machine named :status is defined with :field_name => 'status' " do
          before do
            ExampleRecord.machine(:status, :field_name => 'status') do
              event( :go, :from => :initial, :to => :final )
            end
            @ex = ExampleRecord.new()
          end

          it "should have a binding for .status" do
            @ex.status.should be_kind_of( StateFu::Binding )
          end

          it "should have an ActiveRecord persister with the field_name :status" do
            @ex.status.persister.should be_kind_of( StateFu::Persistence::ActiveRecord )
            @ex.status.persister.field_name.should == :status
          end

          it "should have a value of nil for the status field before state_fu is called" do
            @ex.read_attribute('status').should be_nil
          end

          it "should have the ActiveRecord setter method .status=" do
            @ex.status= 'damp'
            @ex.read_attribute(:status).should == 'damp'
          end

          it "should raise StateFu::InvalidState if the status field is set to a bad value and .status is called" do
            @ex.status= 'damp'
            lambda { @ex.status }.should raise_error( StateFu::InvalidStateName )
          end
        end
      end # second machine
    end   # with before_create filter
  end     # default machine
rescue MissingSourceFile => e
  STDERR.puts "ERROR - Cannot test ActiveRecord persistence (active_record and sqlite3 required): #{e}"
end

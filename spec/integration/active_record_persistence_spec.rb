require File.expand_path("#{File.dirname(__FILE__)}/../helper")

##
##
##


# class ExampleRecord < ActiveRecord::Base
#
#   include StateFu
#
#   validates_presence_of :name
#
#   machine do
#     state :initial do
#       event :change, :to => :final
#     end
#   end
#
#   before_create :state_fu!
# end
#
require 'active_record'

class CreateTables < ActiveRecord::Migration
  def self.up
    create_table :example_records do |t|
      t.string :name,                  :null => false
      t.string :example_machine_state, :null => false
      t.timestamps
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration.new()
  end
end

describe "an ActiveRecord model with StateFu " do

  include MySpecHelper
  before(:each) do

    reset!
    make_pristine_class( 'ExampleRecord', ActiveRecord::Base )
    ExampleRecord.class_eval do
      validates_presence_of :name

      machine do
        state :initial do
          event :change, :to => :final
        end
      end

      before_create :state_fu!
    end
    @db_config = {
      :adapter  => 'sqlite3',
      :database => ':memory:'
    }
    ActiveRecord::Base.establish_connection( @db_config )
    CreateTables.migrate( :up )
  end

  it "should be a subclass of ActiveRecord::Base" do
    ExampleRecord.superclass.should == ActiveRecord::Base
  end

  it "should have a machine with two states and an event" do
    machine = ExampleRecord.machine( )
    machine.should be_kind_of( StateFu::Machine )
    machine.states.length.should == 2
    machine.events.length.should == 1
  end

  it "should have an active_record persister with the field_name 'example_machine_state' " do
    ex = ExampleRecord.new( :name => "exemplar" )
    ex.state_fu
    ex.state_fu.should be_kind_of( StateFu::Binding )
    ex.state_fu.persister.field_name.should == :om_state
    ex.state_fu.persister.should be_kind_of( StateFu::Persistence::ActiveRecord )

  end

  it "should create a record given only a name" do
    pending()
    ex = ExampleRecord.new( :name => "exemplar" )
    ex.should be_valid
    ex.save!
    ex.should_not be_new_record
  end


end

#!/usr/bin/env ruby
thisdir = File.expand_path(File.dirname(__FILE__))
$: << thisdir << "#{thisdir}/../lib"
# $: << thisdir << "#{thisdir}/vendor"

require 'rubygems'
require 'rr'
require 'spec'
require 'state-fu'
require File.join( thisdir, '..' , 'lib', 'no_stdout' )

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module MySpecHelper
  include NoStdout

  def prepare_active_record( options={}, &migration )
    begin
      require 'active_record'
    rescue MissingSourceFile => e
      STDERR.puts "failed to load active_record - skipping specifications!"
      return false
    end

    options.symbolize_keys!
    options.assert_valid_keys( :db_config, :migration_name, :hidden )

    # connect ActiveRecord
    db_config = options.delete(:db_config) || {
      :adapter  => 'sqlite3',
      :database => ':memory:'
    }
    ActiveRecord::Base.establish_connection( db_config )

    return unless block_given?

    # prepare the migration
    migration_class_name =
      options.delete(:migration_name) || 'BeforeSpecMigration'
    make_pristine_class( migration_class_name, ActiveRecord::Migration )
    migration_class = migration_class_name.constantize
    migration_class.class_eval( &migration )

    # run the migration without spewing crap everywhere
    if options.delete(:hidden) != false
      no_stdout { migration_class.migrate( :up ) }
    else
      migration_class.migrate( :up )
    end
  end

  def make_pristine_class(class_name, superklass=Object, reset_first = false)
    reset! if reset_first
    @class_names ||= []
    @class_names << class_name
    klass = Class.new( superklass )
    klass.send( :include, StateFu )
    Object.send(:remove_const, class_name ) if Object.const_defined?( class_name )
    Object.const_set(class_name, klass)
  end

  def reset!
    @class_names ||= []
    @class_names.each do |class_name|
      Object.send(:remove_const, class_name ) if Object.const_defined?( class_name )
    end
    @class_names = []
    StateFu::FuSpace.reset!
  end

  def set_method_arity( object, method_name, needed_arity = 1 )
    a = Object.new
    stub( a ).arity() { needed_arity }
    stub( object ).method(method_name) { a }
  end

end

#!/usr/bin/env ruby
thisdir = File.expand_path(File.dirname(__FILE__))

# ensure we require state-fu from lib, not gems
$LOAD_PATH.unshift( "#{thisdir}/../lib" )
require 'state-fu'
require 'no_stdout'

StateFu::Logger.suppress!

require 'rubygems'

{"rr" => "rr", "spec" => "rspec" }.each do |lib, gem_name|
  begin
    require lib
  rescue LoadError => e
    STDERR.puts "The '#{gem_name}' gem is required to run StateFu's specs. Please install it by running (as root):\ngem install #{gem_name}\n\n"
    exit 1;
  end
end

# require 'state-fu'

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module MySpecHelper
  include NoStdout

  def prepare_active_record( options={}, &migration )
    if skip_slow_specs?
      skip_slow_specs and return false
    end

    begin
      require 'activesupport'
      require 'active_record'
      require 'sqlite3'
    rescue LoadError => e
      pending "skipping specifications due to load error: #{e}"
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

  def skip_slow_specs?
    !!ENV['SKIP_SLOW_SPECS']
  end

  def skip_slow_specs
    pending('Skipping slow specs - run $ rake all if you want them')
  end

  def skip_unless_relaxdb
    unless Object.const_defined?( 'RelaxDB' )
      pending('Skipping specs because you do not have the relaxdb gem (paulcarey-relaxdb) installed ...')
    end
  end

  def prepare_relaxdb( options={} )
    if skip_slow_specs?
      return false
    end
    begin
      require 'relaxdb'
      if Object.const_defined?( "RelaxDB" )
        RelaxDB.configure :host => "localhost", :port => 5984, :design_doc => "spec_doc"
        RelaxDB.delete_db "relaxdb_spec" rescue "ok"
        RelaxDB.use_db    "relaxdb_spec"
        RelaxDB.enable_view_creation
      end
    rescue LoadError => e
      # pending "skipping specifications due to load error: #{e}"
      return false
    end
    begin
      RelaxDB.replicate_db "relaxdb_spec_base", "relaxdb_spec"
      RelaxDB.enable_view_creation
    rescue => e
      puts "\n===== Run rake create_base_db before the first spec run ====="
      puts
      exit!
    end
    #
  end

  def make_pristine_class(class_name, superklass=Object)
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
  end

  def set_method_arity( object, method_name, needed_arity = 1 )
    a = Proc.new {}
    stub( a ).arity() { needed_arity }
    stub( object ).method( anything ) { |x| object.send(x) }
    stub( object ).method( method_name ) { a }
  end

end

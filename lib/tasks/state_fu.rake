namespace :state_fu do

  STATE_FU_APP_PATH      = Object.const_defined?('RAILS_ROOT') ? RAILS_ROOT : File.join( File.dirname(__FILE__), '/../..')
  STATE_FU_PLUGIN_PATH   = Object.const_defined?('RAILS_ROOT') ? File.join( RAILS_ROOT, '/vendor/plugins/state-fu' ) : STATE_FU_APP_PATH

  task :update do
    path = STATE_FU_PLUGIN_PATH
    pwd = FileUtils.pwd
    FileUtils.cd( path )
    system('git pull')
    FileUtils.cd pwd
  end

  def graph_name( klass, workflow, doc_path = false )
    parts = ["#{klass}_#{workflow}"]
    if doc_path
      folder = parts.unshift( File.join( STATE_FU_APP_PATH, "doc/") )
      FileUtils.mkdir( folder )
      parts.push( '.png' )
    end
    parts.join
  end

  def graph( klass, workflow )
    name = graph_name( klass, workflow )
    graphviz = `which dot` # '/opt/local/bin/dot'
    tmp_dot  = "/tmp/#{name}.dot"
    klass.workflow( workflow.to_sym ).graphviz.save_as( tmp_dot )
    tmp_png = tmp_dot + '.png'
    doc_png = graph_name( klass, workflow, true )
    puts( "#{graphviz} -Tpng -O #{tmp_dot}" )
    system( "#{graphviz} -Tpng -O #{tmp_dot}" )
    # puts $?.inspect
    # puts "#{ tmp_png}, #{doc_png}"
    FileUtils.cp tmp_png, doc_png
    doc_png
  end

  task :graph => :environment do |t|
    StateFu::FuSpace.each do |klass, machines|
      machines.each do |machine|
        doc_png = graph( klass, machine )
        # yield doc_png if block_given?
      end
    end
    # `open #{doc_png}`
  end
end


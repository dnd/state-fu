require 'fileutils'

unless Object.const_defined?('STATE_FU_APP_PATH')
  STATE_FU_APP_PATH = Object.const_defined?('RAILS_ROOT') ? RAILS_ROOT : File.join( File.dirname(__FILE__), '/../..')
end

unless Object.const_defined?('STATE_FU_PLUGIN_PATH')
  STATE_FU_PLUGIN_PATH = Object.const_defined?('RAILS_ROOT') ? File.join( RAILS_ROOT, '/vendor/plugins/state-fu' ) : STATE_FU_APP_PATH
end

namespace :spec do
  def find_last_modified_spec
    require 'find'
    specs = []
    Find.find( File.expand_path(File.join(STATE_FU_APP_PATH,'spec'))) do |f|
      next unless f !~ /\.#/ && f =~ /_spec.rb$/
      specs << f
    end
    spec = specs.sort_by { |spec| File.stat( spec ).mtime }.last
  end

  desc "runs the last modified spec, without mucking about"
  Spec::Rake::SpecTask.new(:last) do |t|
    t.spec_opts = ['--options', "\"#{STATE_FU_APP_PATH}/spec/spec.opts\""]
    t.spec_files = FileList[find_last_modified_spec]
  end
end

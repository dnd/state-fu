#!/usr/bin/ruby1.9
require "spec/rake/spectask"
#require 'cucumber/rake/task'
require "date"
require "fileutils"
require "rubygems"

load File.join( File.dirname(__FILE__),"/lib/tasks/state_fu.rake" )

module Rakefile
  def self.windows?
    /djgpp|(cyg|ms|bcc)win|mingw/ =~ RUBY_PLATFORM
  end
end

load 'lib/tasks/spec_last.rake'
load 'lib/tasks/state_fu.rake'

# to build the gem:
#
# gem install jeweller
# rake build
# rake install
begin
  require 'jeweler'
  Jeweler::Tasks.new do |s| # gemspec (Gem::Specification)
  s.name              = "state-fu"
  s.rubyforge_project = "state-fu"
  s.platform          = Gem::Platform::RUBY
  s.has_rdoc          = true
#  s.extra_rdoc_files  = ["README.rdoc"]
  s.summary           = "A rich library for state-oriented programming with state machines / workflows"
  s.description       = s.summary
  s.author            = "David Lee"
  s.email             = "david@rubyist.net.au"
  s.homepage          = "http://github.com/davidlee/state-fu"
  s.require_path      = "lib"
#  s.files             = %w(README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
  s.files             = %w(Rakefile) + Dir.glob("{lib,spec}/**/*")
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

namespace :spec do
  desc "Run all specs"
  Spec::Rake::SpecTask.new(:all) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
    t.spec_opts = ["--options", "spec/spec.opts"]
  end

  desc "Run unit specs"
  Spec::Rake::SpecTask.new(:units) do |t|
    t.spec_files = FileList["spec/units/*_spec.rb"]
    t.spec_opts = ["--options", "spec/spec.opts"]
  end
  task :unit => :units

  desc "Run integration specs"
  Spec::Rake::SpecTask.new(:integration) do |t|
    t.spec_files = FileList["spec/integration/*_spec.rb"]
    t.spec_opts = ["--options", "spec/spec.opts"]
  end
  task :system => :integration

  desc "Print Specdoc for all specs (eaxcluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_files = FileList["spec/**/*_spec.rb"]
    t.spec_opts  = ["--format", "nested","--backtrace","--color"]
  end

  desc "Run autotest"
  task :auto do |t|
    exec 'autospec'
  end
end

desc 'Runs irb in this project\'s context'
task :irb do |t|
  exec 'irb -I lib -r state-fu'
end

desc 'Runs rdoc on the project lib directory'
task :doc do |t|
  exec 'rdoc lib/'
end

begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
      t.cucumber_opts = "--format pretty"
  end
rescue LoadError => e
end

task :default => 'spec:all'

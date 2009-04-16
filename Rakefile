#!/usr/bin/ruby1.9
require "spec/rake/spectask"
require 'cucumber/rake/task'
require "date"
require "fileutils"
require "rubygems"
require "rake/gempackagetask"

require "./lib/state_fu/version.rb"

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "--format pretty" # Any valid command line option can go here.
end

module Rakefile
  def self.windows?
    /djgpp|(cyg|ms|bcc)win|mingw/ =~ RUBY_PLATFORM
  end
end

state_fu_gemspec = Gem::Specification.new do |s|
  s.name              = "state-fu"
  s.rubyforge_project = "state-fu"
  s.version           = StateFu::VERSION
  s.platform          = Gem::Platform::RUBY
  s.has_rdoc          = true
#  s.extra_rdoc_files  = ["README.rdoc"]
  s.summary           = "A rich library for defining finite state machines & workflows"
  s.description       = s.summary
  s.author            = "David Lee"
  s.email             = "david@rubyist.net.au"
  s.homepage          = "http://github.com/davidlee/state-fu"
  s.require_path      = "lib"
#  s.files             = %w(README.rdoc Rakefile) + Dir.glob("{lib,spec}/**/*")
  s.files             = %w(Rakefile) + Dir.glob("{lib,spec}/**/*")
end

Rake::GemPackageTask.new(state_fu_gemspec) do |pkg|
  pkg.gem_spec = state_fu_gemspec
end

namespace :gem do
  desc "Build and install as a RubyGem"
  task :install => :package do
    sh %{#{'sudo' unless Rakefile.windows?} gem install --local pkg/state-fu-#{StateFu::VERSION}*}
  end

  desc "Generate state-fu.gemspec"
  task :spec do
    unless ENV["RELEASE"] == "true"
      state_fu_gemspec.version = "#{StateFu::VERSION}.#{Time.now.strftime("%Y%m%d%H%M")}"
    end

    File.open("state-fu.gemspec", "w") do |f|
      f.puts(state_fu_gemspec.to_ruby)
    end
  end
end

namespace :spec do
  desc "Run both units and integration specs"
  task :both => [:units, :integration]

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

desc "Keep things tidy"
task :clean => :clobber_package

desc 'Runs irb in this project\'s context'
task :irb do |t|
  exec 'irb -I lib -r state-fu'
end

desc 'Runs rdoc on the project lib directory'
task :doc do |t|
  exec 'rdoc lib/'
end

task :default => 'spec:all'

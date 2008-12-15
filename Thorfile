require 'rubygems'
require 'rubygems/specification'
require 'thor/tasks'
require 'lib/ruby-yui/yui'

GEM = "ruby-yui"
GEM_VERSION = Yui.version
AUTHOR = "Cory O'Daniel"
EMAIL = "ruby-yui@coryodaniel.com"
HOMEPAGE = "http://coryodaniel.com"
SUMMARY = "A ruby wrapper for YUI compressor"
PROJECT = "ruby-yui"

SPEC = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.rubyforge_project = PROJECT
    
  s.require_path = 'lib'
  s.bindir = "bin"
  s.executables = []
  s.files = s.extra_rdoc_files + %w(Thorfile) + Dir.glob("{ext,lib,test,spec}/**/*")
end

class Default < Thor
  # Set up standard Thortasks
  spec_task(Dir["spec/**/*_spec.rb"])
  spec_task(Dir["spec/**/*_spec.rb"], :name => "rcov", :rcov =>
    {:exclude => %w(spec /Library /Users task.thor lib/getopt.rb)})
  install_task SPEC
  
  desc "gemspec", "make a gemspec file"
  def gemspec
    File.open("#{GEM}.gemspec", "w") do |file|
      file.puts SPEC.to_ruby
    end    
  end
end

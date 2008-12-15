# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ruby-yui}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cory O'Daniel"]
  s.date = %q{2008-12-15}
  s.description = %q{A ruby wrapper for YUI compressor}
  s.email = %q{ruby-yui@coryodaniel.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["README", "Thorfile", "lib/ruby-yui", "lib/ruby-yui/yui.rb", "lib/ruby-yui.rb", "test/data", "test/data/javascripts", "test/data/javascripts/jquery-1.2.6.js", "test/data/javascripts/prototype.js", "test/data/stylesheets"]
  s.has_rdoc = true
  s.homepage = %q{http://coryodaniel.com}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-yui}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A ruby wrapper for YUI compressor}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

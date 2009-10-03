require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "shift_subtitle"
    gem.summary = %Q{Ruby Challenge #1: Shift Subtitle}
    gem.description = %Q{Submission for the Ruby Challenge to create a command line tool to shift SubRib formatted movie subtitles}
    gem.email = "thuss@gabrito.com"
    gem.homepage = "http://github.com/thuss/shift_subtitle"
    gem.authors = ["Todd Huss"]
    gem.add_development_dependency "rspec"
  end
rescue LoadError
  puts "Jeweler is not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
  spec.rcov_opts = ['--exclude', 'lib/spec,bin/spec,spec/*,rcov*']
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "shift_subtitle #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

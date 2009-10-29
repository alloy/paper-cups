require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "peiji-san"
    s.homepage = "http://github.com/Fingertips/peiji-san"
    s.email    = "eloy.de.enige@gmail.com"
    s.authors  = ["Eloy Duran"]
    s.summary  = s.description = "PeijiSan is a Rails plugin which uses named scopes to create a thin pagination layer."
    s.files    = FileList['**/**'] # tmp until we've patched Jeweler to be able to easily add files to defaults
  end
rescue LoadError
end

begin
  require 'jewelry_portfolio/tasks'
  JewelryPortfolio::Tasks.new do |p|
    p.account = 'Fingertips'
  end
rescue LoadError
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'PeijiSan'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=utf-8'
  rdoc.rdoc_files.include('README*', 'LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = false
end

task :default => :test

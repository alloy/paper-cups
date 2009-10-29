require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the risosu-san plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the risosu-san plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Risosu-san'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=utf8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('LICENSE')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "risosu-san"
    s.homepage = "http://github.com/Fingertips/risosu-san"
    s.email    = "eloy.de.enige@gmail.com"
    s.authors  = ["Eloy Duran"]
    s.summary  = s.description = "RisosuSan is a Rails plugin that assists in situations where a resource controller is nested under another resource."
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
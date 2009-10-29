require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the authentication_needed_san plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the authentication_needed_san plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'AuthenticationNeeded-San'
  rdoc.options << '--line-numbers' << '--inline-source' << '--charset=utf-8'
  rdoc.rdoc_files.include('README.rdoc', 'lib/authentication_needed_san.rb', 'LICENSE')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name     = "authentication-needed-san"
    s.summary  = s.description = "A thin wrapper around the Rails `flash' object to assist in redirecting the user `back' after authentication."
    s.email    = "eloy@fngtps.com"
    s.homepage = "http://github.com/Fingertips/authentication-needed-san"
    s.authors  = ["Eloy Duran"]
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
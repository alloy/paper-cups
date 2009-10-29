# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{validates_email-san}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran", "Manfred Stienstra"]
  s.date = %q{2009-09-07}
  s.description = %q{A simple Rails plugin which adds a validates_email class method to ActiveRecord::Base.}
  s.email = %q{eloy@fngtps.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/validates_email_san.rb",
    "rails/init.rb",
    "test/test_helper.rb",
    "test/validates_email_san_test.rb"
  ]
  s.homepage = %q{http://fingertips.github.com}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A simple Rails plugin which adds a validates_email class method to ActiveRecord::Base.}
  s.test_files = [
    "test/test_helper.rb",
    "test/validates_email_san_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

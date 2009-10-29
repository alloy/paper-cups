# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authentication-needed-san}
  s.version = "1.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-06-11}
  s.description = %q{A thin wrapper around the Rails `flash' object to assist in redirecting the user `back' after authentication.}
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
    "lib/authentication_needed_san.rb",
    "rails/init.rb",
    "test/authentication_needed_san_test.rb",
    "test/test_helper.rb"
  ]
  s.homepage = %q{http://github.com/Fingertips/authentication-needed-san}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A thin wrapper around the Rails `flash' object to assist in redirecting the user `back' after authentication.}
  s.test_files = [
    "test/authentication_needed_san_test.rb",
    "test/test_helper.rb"
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

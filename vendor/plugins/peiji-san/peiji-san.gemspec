# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{peiji-san}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eloy Duran"]
  s.date = %q{2009-03-09}
  s.description = %q{PeijiSan is a Rails plugin which uses named scopes to create a thin pagination layer.}
  s.email = %q{eloy.de.enige@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "LICENSE"]
  s.files = ["lib", "lib/peiji_san", "lib/peiji_san/view_helper.rb", "lib/peiji_san.rb", "LICENSE", "peiji-san.gemspec", "rails", "rails/init.rb", "Rakefile", "README.rdoc", "test", "test/peiji_san_test.rb", "test/test_helper.rb", "test/view_helper_test.rb", "VERSION.yml"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/Fingertips/peiji-san}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{PeijiSan is a Rails plugin which uses named scopes to create a thin pagination layer.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

require File.expand_path("lib/with_validations/version")

Gem::Specification.new do |s|
  s.name        = "with_validations"
  s.version     = WithValidations::VERSION
  s.authors     = ["Stefan Rohlfing"]
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.description = <<-DESCRIPTION
Elegant validation of option keys and values. Installation and usage is very simple. You find all
the information you need on the homepage listed below.
DESCRIPTION
  s.summary               = 'WithValidation - Easy validation of option keys and values.'
  s.email                 = 'stefan.rohlfing@gmail.com'
  s.homepage              = 'http://github.com/bytesource/with_validations'
  s.has_rdoc              = 'yard'
  s.required_ruby_version = '>= 1.9.1'
  s.rubyforge_project     = 'with_validations'

  s.add_development_dependency 'rspec'

  s.files = Dir["{lib}/**/*.rb", "*.md", 'Rakefile', 'LICENSE']
end

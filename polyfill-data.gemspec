# frozen_string_literal: true

require_relative "lib/polyfill/data/version"

Gem::Specification.new do |spec|
  spec.name = "polyfill-data"
  spec.version = Polyfill::Data::VERSION
  spec.authors = ["Jim Gay"]
  spec.email = ["jim@saturnflyer.com"]

  spec.summary = "Add the ruby 3.2 Data class to older rubies"
  spec.description = "Add the ruby 3.2 Data class to older rubies"
  spec.license = "MIT"
  spec.homepage = "https://github.com/saturnflyer/polyfill-data"
  spec.required_ruby_version = ">= 2.6.0", "< 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/saturnflyer/polyfill-data.git"

  spec.files = Dir["lib/**/*"] + ["Rakefile", "README.md"]
  spec.test_files = Dir["test/*"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.cert_chain  = ['certs/saturnflyer.pem']
  spec.signing_key = File.expand_path("~/.gem/gem-private_key.pem") if $0 =~ /gem\z/
end


lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sql_assess/version"

Gem::Specification.new do |spec|
  spec.name          = "sql_assess"
  spec.version       = SqlAssess::VERSION
  spec.authors       = ["Vlad Stoica"]
  spec.email         = ["vlad96stoica@gmail.com"]

  spec.summary       = "Ruby gem for assesing SQL"
  spec.homepage      = "https://vladstoica.com"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "mysql2"
  spec.add_dependency 'sql-parser-vlad', '~> 0.0.15'
  spec.add_dependency "rgl"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "rubocop", '~> 0.54.0'
  spec.add_development_dependency "codecov"
end

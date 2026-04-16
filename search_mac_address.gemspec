
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "search_mac_address/version"

Gem::Specification.new do |spec|
  spec.name          = "search_mac_address"
  spec.version       = SearchMacAddress::VERSION
  spec.authors       = ["Shiv Raj Badu"]
  spec.email         = ["shivrajbadu@gmail.com"]

  spec.summary       = %q{Search mac address of your system, encode and decode mechanism}
  spec.description   = %q{Get mac address, encode and save.}
  spec.homepage      = "https://github.com/userrails/search-mac-address"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || f.end_with?('.gem')
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.16"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.0"
end

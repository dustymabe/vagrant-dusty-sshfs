# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-dusty-sshfs/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-dusty-sshfs"
  spec.version       = VagrantPlugins::SyncedFolderSSHFS::VERSION
  spec.authors       = ["Dusty Mabe"]
  spec.email         = ["dusty@dustymabe.com"]
  spec.description   = "A Vagrant plugin that mounts folders with sshfs."
  spec.summary       = spec.description
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

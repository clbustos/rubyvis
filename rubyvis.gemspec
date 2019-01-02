# -*- encoding: utf-8 -*-
require_relative "lib/rubyvis/version.rb"

Gem::Specification.new do |s|
  s.name = "rubyvis"
  s.version = Rubyvis::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Claudio Bustos']
  s.email = []
  s.homepage = "http://rubygems.org/gems/rubyvis"
  s.summary = "Rubyvis"
  s.description = "Rubyvis"

  s.required_rubygems_version = ">= 1.3.6"
  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec"
  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end

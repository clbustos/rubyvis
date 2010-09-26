# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'rubygems'
require 'hoe'
require 'protoruby'
Hoe.plugin :git
Hoe.spec 'protoruby' do
  self.testlib=:rspec
  self.test_globs="spec/*_spec.rb"
  self.rubyforge_name = 'ruby-statsample' # if different than 'protoruby'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.version=Protoruby::VERSION
end

# vim: syntax=ruby

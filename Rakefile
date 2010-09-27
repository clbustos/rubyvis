# -*- ruby -*-
$:.unshift(File.dirname(__FILE__)+"/lib")
require 'rubygems'
require 'hoe'
require 'rubyvis'
Hoe.plugin :git
Hoe.spec 'rubyvis' do
  self.testlib=:rspec
  self.test_globs="spec/*_spec.rb"
  self.rubyforge_name = 'rubyvis' # if different than 'protoruby'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.version=Rubyvis::VERSION
end

# vim: syntax=ruby

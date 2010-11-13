# -*- ruby -*-
$:.unshift(File.expand_path(File.dirname(__FILE__)+"/lib"))
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'hoe'
require 'rubyvis'
require 'rspec'
require 'rspec/core/rake_task'




RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end


Hoe.plugin :git

Hoe.spec 'rubyvis' do
  self.testlib=:rspec
  self.test_globs="spec/*_spec.rb"
#  self.rubyforge_name = 'rubyvis'
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.version=Rubyvis::VERSION
  self.extra_dev_deps << ["coderay",">=0"] << ["haml",">=0"] << ["nokogiri", ">=0"] << ["rspec",">=2.0"]
end

# vim: syntax=ruby

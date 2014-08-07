# -*- ruby -*-
$:.unshift(File.expand_path(File.dirname(__FILE__)+"/lib"))
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'rubyvis'
require 'rspec'
require 'rspec/core/rake_task'
require './lib/rspec/expectations/differ'

require 'bundler'
Bundler::GemHelper.install_tasks



desc "Publicar docs en rubyforge"
task :publicar_docs => [:clean, :docs] do
  #ruby %{agregar_adsense_a_doc.rb}
  path = File.expand_path("~/.rubyforge/user-config.yml")
  config = YAML.load(File.read(path))
  host = "#{config["username"]}@rubyforge.org"
  
  remote_dir = "/var/www/gforge-projects/#{h.rubyforge_name}/#{h.remote_rdoc_dir
  }"
  local_dir = h.local_rdoc_dir
  Dir.glob(local_dir+"/**/*") {|file|
    sh %{chmod 755 #{file}}
  }
  sh %{rsync #{h.rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end


# vim: syntax=ruby

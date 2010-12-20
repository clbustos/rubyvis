# -*- ruby -*-
$:.unshift(File.expand_path(File.dirname(__FILE__)+"/lib"))
$:.unshift(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'hoe'
require 'rubyvis'
require 'rspec'
require 'rspec/core/rake_task'


Hoe.plugin :git

h=Hoe.spec 'rubyvis' do
  self.testlib=:rspec
  #self.test_globs="spec/*_spec.rb"
  self.rspec_options << "-c" << "-b"
  self.developer('Claudio Bustos', 'clbustos_at_gmail.com')
  self.version=Rubyvis::VERSION
  self.extra_dev_deps << ["coderay",">=0"] << ["haml",">=0"] << ["nokogiri", ">=0"] << ["rspec",">=2.0"]
end

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

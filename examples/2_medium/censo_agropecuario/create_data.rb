require 'statsample'
a=Statsample::CSV.read('resultset.csv')
File.open("censo_agropecuario_chile_data.rb","w") do |fp|
  fp.puts "# encoding: UTF-8"
  fp.puts "$censo = ["
  a.each do |row|
    fp.puts row.inject({}) {|ac,v| ac[v[0].to_sym]=v[1];ac}.inspect+","
  end
  fp.puts "]"
end

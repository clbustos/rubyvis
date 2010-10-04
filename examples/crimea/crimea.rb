$:.unshift(File.dirname(__FILE__)+"/../../lib")
require 'rubyvis'
require 'ostruct'

$causes = ["wounds", "other", "disease"];

$crimea = [
  OpenStruct.new({ date: "4/1854", wounds: 0, other: 110, disease: 110 }),
  OpenStruct.new({ date: "5/1854", wounds: 0, other: 95, disease: 105 }),
  OpenStruct.new({ date: "6/1854", wounds: 0, other: 40, disease: 95 }),
  OpenStruct.new({ date: "7/1854", wounds: 0, other: 140, disease: 520 }),
  OpenStruct.new({ date: "8/1854", wounds: 20, other: 150, disease: 800 }),
  OpenStruct.new({ date: "9/1854", wounds: 220, other: 230, disease: 740 }),
  OpenStruct.new({ date: "10/1854", wounds: 305, other: 310, disease: 600 }),
  OpenStruct.new({ date: "11/1854", wounds: 480, other: 290, disease: 820 }),
  OpenStruct.new({ date: "12/1854", wounds: 295, other: 310, disease: 1100 }),
  OpenStruct.new({ date: "1/1855", wounds: 230, other: 460, disease: 1440 }),
  OpenStruct.new({ date: "2/1855", wounds: 180, other: 520, disease: 1270 }),
  OpenStruct.new({ date: "3/1855", wounds: 155, other: 350, disease: 935 }),
  OpenStruct.new({ date: "4/1855", wounds: 195, other: 195, disease: 560 }),
  OpenStruct.new({ date: "5/1855", wounds: 180, other: 155, disease: 550 }),
  OpenStruct.new({ date: "6/1855", wounds: 330, other: 130, disease: 650 }),
  OpenStruct.new({ date: "7/1855", wounds: 260, other: 130, disease: 430 }),
  OpenStruct.new({ date: "8/1855", wounds: 290, other: 110, disease: 490 }),
  OpenStruct.new({ date: "9/1855", wounds: 355, other: 100, disease: 290 }),
  OpenStruct.new({ date: "10/1855", wounds: 135, other: 95, disease: 245 }),
  OpenStruct.new({ date: "11/1855", wounds: 100, other: 140, disease: 325 }),
  OpenStruct.new({ date: "12/1855", wounds: 40, other: 120, disease: 215 }),
  OpenStruct.new({ date: "1/1856", wounds: 0, other: 160, disease: 160 }),
  OpenStruct.new({ date: "2/1856", wounds: 0, other: 100, disease: 100 }),
  OpenStruct.new({ date: "3/1856", wounds: 0, other: 125, disease: 90 })
];

format= pv.Format::Date.new("%m/%Y");
$crimea.each_with_index {|d,i|
  d.date = format.parse(d.date)
}
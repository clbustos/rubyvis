$:.unshift(File.dirname(__FILE__)+"/../lib")
require 'protoruby'
causes = ["wounds", "other", "disease"];

crimea = [
  { date: "4/1854", wounds: 0, other: 110, disease: 110 },
  { date: "5/1854", wounds: 0, other: 95, disease: 105 },
  { date: "6/1854", wounds: 0, other: 40, disease: 95 },
  { date: "7/1854", wounds: 0, other: 140, disease: 520 },
  { date: "8/1854", wounds: 20, other: 150, disease: 800 },
  { date: "9/1854", wounds: 220, other: 230, disease: 740 },
  { date: "10/1854", wounds: 305, other: 310, disease: 600 },
  { date: "11/1854", wounds: 480, other: 290, disease: 820 },
  { date: "12/1854", wounds: 295, other: 310, disease: 1100 },
  { date: "1/1855", wounds: 230, other: 460, disease: 1440 },
  { date: "2/1855", wounds: 180, other: 520, disease: 1270 },
  { date: "3/1855", wounds: 155, other: 350, disease: 935 },
  { date: "4/1855", wounds: 195, other: 195, disease: 560 },
  { date: "5/1855", wounds: 180, other: 155, disease: 550 },
  { date: "6/1855", wounds: 330, other: 130, disease: 650 },
  { date: "7/1855", wounds: 260, other: 130, disease: 430 },
  { date: "8/1855", wounds: 290, other: 110, disease: 490 },
  { date: "9/1855", wounds: 355, other: 100, disease: 290 },
  { date: "10/1855", wounds: 135, other: 95, disease: 245 },
  { date: "11/1855", wounds: 100, other: 140, disease: 325 },
  { date: "12/1855", wounds: 40, other: 120, disease: 215 },
  { date: "1/1856", wounds: 0, other: 160, disease: 160 },
  { date: "2/1856", wounds: 0, other: 100, disease: 100 },
  { date: "3/1856", wounds: 0, other: 125, disease: 90 }
];
format = pv.Format.date("%m/%y");
crimea=crimea.map {|d| d[:date] = format.parse(d[:date]); d}




w = 545
h = 280
x = pv.Scale.linear(crimea, lambda {|d|  d[:date]}).range(0, w)
y = pv.Scale.linear(0, 1500).range(0, h)

fill = pv.colors("lightpink", "darkgray", "lightblue")
format = pv.Format.date("%b")

vis = pv.Panel.new()
      .width(w)
      .height(h)
      .margin(19.5)
      .right(40);

vis.add(pv.Panel)
    .data(causes)
    .add(pv.Line)
    .data(crimea)
    .left(lambda {|d| x.scale(d.date)})
    .bottom(lambda {|d,t| y.scale(d[t])})
    .strokeStyle(fill.by(pv.parent))
    .lineWidth(3);

vis.add(pv.Label).data(x.ticks()).left(x).bottom(0).text_baseline("top").text_margin(5).text(pv.Format.date("%b"));

vis.add(pv.Rule).data(y.ticks()).bottom(y).stroke_style(lambda {|i| i ? "#ccc" : "black"}).anchor("right").add(pv.Label).visible(lambda {!(self.index & 1)}).textMargin(6);

vis.render()
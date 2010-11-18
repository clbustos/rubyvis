module Rubyvis
  def self.histogram(data,f=nil)
    Rubyvis::Histogram.new(data,f)
  end
  class Histogram
    module Bin
      attr_accessor :x, :dx, :y
    end
    attr_accessor :frequency
    attr_reader :data
    attr_reader :f
    def initialize(data,f=nil)
      @data=data
      @f=f
      @frequency=true
    end
    def bins(ticks=nil)
      x=Rubyvis.map(data,f)
      bins=[]
      ticks||=Rubyvis::Scale.linear(x).ticks()
      # Initialize the bins
      (ticks.size-1).times {|i|
        bin=bins[i]=[]
        bin.extend Bin
        bin.x=ticks[i]
        bin.dx=ticks[i+1]-ticks[i]
        bin.y=0
      }
      x.size.times {|i|
        j=Rubyvis.search_index(ticks, x[i])-1
        bin=bins[ [0,[bins.size-1,j].min].max]
        bin.y+=1
        bin.push(data[i])
      }
      if !@frequency
        bins.each {|b|
          b.y=b.y/x.size.to_f
        }
      end
      bins
    end
    
  end
end

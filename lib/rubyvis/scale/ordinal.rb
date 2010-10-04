module Rubyvis
  class Scale::Ordinal
    include Rubyvis::Scale
    attr_reader :range_band
    def initialize(*args)
      @d=[] # domain
      @i={}
      @r=[]
      @range_band=nil
      @band=0
      domain(*args)
    end
    def scale(x)
      if @i[x].nil?
        @d.push(x)
        @i[x]=@d.size-1
      end
      @r[@i[x] % @r.size]
    end
    def domain(*arguments)
      array,f=arguments[0],arguments[1]
      if(arguments.size>0)
      array= (array.is_a? Array) ? ((arguments.size>1) ? pv.map(array,f) : array) : arguments.dup
        @d=array.uniq
        @i=pv.numerate(@d)
        return self
      end
      @d
    end
    def split_banded(*arguments)
      min,max,band=arguments
      band=1 if (arguments.size < 3)
      if (band < 0) 
        
        n = self.domain().size
        total = -band * n
        remaining = max - min - total
        padding = remaining / (n + 1).to_f
        @r = pv.range(min + padding, max, padding - band);
        @range_band = -band;
      else
        step = (max - min) / (self.domain().size + (1 - band))
        @r = pv.range(min + step * (1 - band), max, step);
        @range_band = step * band;
      end
      return self
    end
    def range(*arguments)
      array, f = arguments[0],arguments[1]
      if(arguments.size>0)
        @r=(array.is_a? Array) ? ((arguments.size>1) ? array.map(&f) : array) : arguments.dup
        if @r[0].is_a? String
          @r=@r.map {|i| pv.color(i)}
        end
        self
      end
      @r
    end
    def split(min,max)
      step=(max-min).quo(domain().size)
      @r=pv.range(min+step.quo(2),max,step)
      self
    end
    def by(*arguments)
      f,dummy=arguments
      t=self
      by=lambda {t.scale(f.js_apply(self,arguments))}
      by
    end
  end
end

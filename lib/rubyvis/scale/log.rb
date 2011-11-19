module Rubyvis
  
  class Scale::Log < Rubyvis::Scale::Quantitative
    def initialize(*args)
      super(*args)
      @b=nil
      @_p=nil
      
      base(10)
    end
    def log(x)
      Math.log(x) / @_p.to_f
    end
    def pow(y)
      @b**y
    end
    def base(v=nil)
      if v
        @b=v
        @_p=Math.log(@b)
        transform(lambda {|x| log(x)}, lambda {|x| pow(x)})
        return self
      end
      return @b
    end
    def nice
      d=domain
      domain(Rubyvis.log_floor(d[0],@b), Rubyvis.log_ceil(d[1],@b))
    end
    # Returns an array of evenly-spaced, suitably-rounded values in the input
    # domain. These values are frequently used in conjunction with
    # Rule to display tick marks or grid lines.
    # 
    # Subdivisions set the number of division inside each base^x
    # By default, is set to base
    def ticks(subdivisions=nil)
      d = domain
      n = d[0] < 0
      subdivisions||=@b
      span=@b.to_f/subdivisions
     # puts "dom: #{d[0]} -> #{n}"
      
      i = (n ? -log(-d[0]) : log(d[0])).floor
      j = (n ? -log(-d[1]) : log(d[1])).ceil
      ticks = [];
      if n
        ticks.push(-pow(-i))
        (i..j).each {|ii|
          ((@b-1)...0).each {|k|
            ticks.push(-pow(-ii) * k)
          }
        }
      else
        (i...j).each {|ii|
          (1..subdivisions).each {|k|
            if k==1
              ticks.push(pow(ii))
            else
              next if subdivisions==@b and k==2
              ticks.push(pow(ii)*span*(k-1))
            end
          }
        }
        ticks.push(pow(j));
      end
      
      # for (i = 0; ticks[i] < d[0]; i++); // strip small values
      # for (j = ticks.length; ticks[j - 1] > d[1]; j--); // strip big values
      # return ticks.slice(i, j);
      ticks.find_all {|v| v>=d[0] and v<=d[1]}
    end
  end
end

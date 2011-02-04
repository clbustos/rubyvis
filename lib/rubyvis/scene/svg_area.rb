module Rubyvis
  module SvgScene
    def self.area(scenes)
      #e = scenes._g.elements[1]
      e=scenes._g.get_element(1)
      return e if scenes.size==0
      s=scenes[0]
      # segmented
      return self.area_segment(scenes) if (s.segmented) 
      # visible
      return e if (!s.visible)
      fill = s.fill_style
      stroke = s.stroke_style
      return e if (fill.opacity==0 and stroke.opacity==0)
      
      # Computes the straight path for the range [i, j]
      path=lambda {|ii,j|
        p1 = []
        p2 = []
        k=j
        (ii..k).each {|i|
          si = scenes[i]
          sj = scenes[j]
          pi = "#{si.left},#{si.top}"
          pj = "#{(sj.left + sj.width)},#{(sj.top + sj.height)}"
          puts "#{i}:"+pi+","+pj if $DEBUG
          #/* interpolate */
          
          if (i < k)
            sk = scenes[i + 1]
            sl = scenes[j - 1]
            case (s.interpolate) 
              when "step-before"
                pi = pi+"V#{sk.top}"
                pj = pj+"H#{sl.left + sl.width}"
              
              when "step-after"
                pi = pi+"H#{sk.left}"
                pj = pj+"V#{sl.top + sl.height}"
            end
          end
    
          p1.push(pi)
          p2.push(pj)
          j=j-1
        }
        (p1+p2).join("L");
      }
        
      # @private Computes the curved path for the range [i, j]. */
      path_curve=lambda {|ii, j|
        pointsT = []
        pointsB = []
        pathT=nil
        pathB=nil
        
        
        k=j
        (ii..k).each {|i|
          sj = scenes[j];
          pointsT.push(scenes[i])
          pointsB.push(OpenStruct.new({:left=> sj.left + sj.width, :top=> sj.top + sj.height}))
          j=j-1
        }
        
        if (s.interpolate == "basis") 
          pathT = Rubyvis::SvgScene.curve_basis(pointsT)
          pathB = Rubyvis::SvgScene.curve_basis(pointsB)
        elsif (s.interpolate == "cardinal") 
            pathT = Rubyvis::SvgScene.curve_cardinal(pointsT, s.tension);
            pathB = Rubyvis::SvgScene.curve_cardinal(pointsB, s.tension);
        elsif # monotone
          pathT = Rubyvis::SvgScene.curve_monotone(pointsT);
          pathB = Rubyvis::SvgScene.curve_monotone(pointsB);
        end
        
        "#{pointsT[0].left },#{ pointsT[0].top }#{ pathT }L#{ pointsB[0].left},#{pointsB[0].top}#{pathB}"
      }
        
      #/* points */
      d = []
      si=nil
      sj=nil
      i=0
      # puts "Scenes:#{scenes.size}, interpolation:#{scenes[0].interpolate}"
      
      while(i < scenes.size)
        si = scenes[i]
        if (si.width==0 and si.height==0)
          i+=1
          next
        end
        
        j=i+1
        while(j<scenes.size) do
          sj=scenes[j]
          break if sj.width==0 and sj.height==0
          j+=1
        end
        
        puts "j:#{j}" if $DEBUG
        
        i=i-1 if (i!=0 and (s.interpolate != "step-after"))
        
        j=j+1 if ((j < scenes.size) and (s.interpolate != "step-before"))
        
        d.push(((j - i > 2 and (s.interpolate == "basis" or s.interpolate == "cardinal" or s.interpolate == "monotone")) ? path_curve : path).call(i, j - 1))
        
        i = j - 1
        i+=1
        
      end
      
      return e if d.size==0
    
      e = self.expect(e, "path", {
        "shape-rendering"=> s.antialias ? nil : "crispEdges",
        "pointer-events"=> s.events,
        "cursor"=> s.cursor,
        "d"=> "M" + d.join("ZM") + "Z",
        "fill"=> fill.color,
        "fill-opacity"=> fill.opacity==0 ? nil : fill.opacity,
        "stroke"=> stroke.color,
        "stroke-opacity"=> stroke.opacity==0 ? nil : stroke.opacity,
        "stroke-width"=> stroke.opacity!=0 ? s.line_width / self.scale : nil
      })
      self.append(e, scenes, 0);
    end
        
    def self.area_segment(scenes)
      e=scenes._g.get_element(1)
      #e = scenes._g.elements[1]
      s = scenes[0]
      pathsT=nil
      pathsB=nil
      if (s.interpolate == "basis" or s.interpolate == "cardinal" or s.interpolate == "monotone") 
        pointsT = []
        pointsB = []
        n=scenes.size
        n.times {|i|
          sj = scenes[n - i - 1]
          pointsT.push(scenes[i])
          pointsB.push(OpenStruct.new({:left=> sj.left + sj.width, :top=> sj.top + sj.height}));
        }
    
        if (s.interpolate == "basis") 
          pathsT = Rubyvis::SvgScene.curve_basis_segments(pointsT)
          pathsB = Rubyvis::SvgScene.curve_basis_segments(pointsB)
        elsif (s.interpolate == "cardinal")
            pathsT = Rubyvis::SvgScene.curve_cardinal_segments(pointsT, s.tension);
            pathsB = Rubyvis::SvgScene.curve_cardinal_segments(pointsB, s.tension);
        elsif # monotone
          pathsT = Rubyvis::SvgScene.curve_monotone_segments(pointsT)
          pathsB = Rubyvis::SvgScene.curve_monotone_segments(pointsB)
        end
      end
      
      n=scenes.size-1
      n.times {|i|
        
        s1 = scenes[i]
        s2 = scenes[i + 1]
    
        # /* visible */
        next if (!s1.visible or !s2.visible)
        
        fill = s1.fill_style
        stroke = s1.stroke_style            
        next if (fill.opacity==0 and stroke.opacity==0)
        
        d=nil
        if (pathsT) 
          pathT = pathsT[i]
          pb=pathsB[n - i - 1]
          pathB = "L" + pb[1,pb.size-1]
          d = pathT + pathB + "Z";
        else 
          #/* interpolate */
          si = s1
          sj = s2
          
          case (s1.interpolate) 
            when "step-before"
              si = s2
            when "step-after"
              sj = s1
          end
          
    
          #/* path */
          d = "M#{s1.left},#{si.top}L#{s2.left},#{sj.top }L#{s2.left + s2.width},#{sj.top + sj.height}L#{s1.left + s1.width},#{si.top + si.height}Z"
        end
    
        e = self.expect(e, "path", {
            "shape-rendering"=> s1.antialias ? nil : "crispEdges",
            "pointer-events"=> s1.events,
            "cursor"=> s1.cursor,
            "d"=> d,
            "fill"=> fill.color,
            "fill-opacity"=> fill.opacity==0 ? nil : fill.opacity,
          "stroke"=> stroke.color,
          "stroke-opacity"=> stroke.opacity==0 ? nil : stroke.opacity,
          "stroke-width"=> stroke.opacity!=0 ? s1.line_width / self.scale : nil
          });
        e = self.append(e, scenes, i);
      }
      return e
    end
  end
end


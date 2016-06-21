#=================================================
# SRPG::SpriteBasic
#-------------------------------------------------
# Update : 12/03/2015
#=================================================

module SRPG
  module SpriteBasic
    module Route
      def self.get_flags(routes)
        # Get Way
        way = [ 0 ]
        1.upto(routes.size-1) do |i|
          d = dir(*routes[i-1],*routes[i])
          way.push(d + 1)
        end
        way.push(0)
        # Get Flags
        flags = Array.new
        return flags if (way.size == 2)
        flags.push(get_flag(0,way[1]-1))
        1.upto(way.size-3) do |i|
          tw = way[i]
          nw = way[i+1]
          if ((tw != nw) && (tw != 0))
            n = get_flag(2,ndir(tw,nw))
          else
            n = get_flag(1,tw-1)
          end
          flags.push(n)
        end
        flags.push(get_flag(3,way[-2]-1))
      end
      def self.dir(fx, fy, tx, ty)
        ((4*(tx-fx)+(ty-fy)+1).abs+1)/2
      end
      def self.ndir(fd, nd)
        n = (fd + nd) / (fd - nd).abs
        n = (n == 5) ? 4 : n
        (fd < nd) ? 4 - n : n - 1
      end
      def self.get_flag(flag, dir)
        flag << 2 | dir
      end
    end
  end
end

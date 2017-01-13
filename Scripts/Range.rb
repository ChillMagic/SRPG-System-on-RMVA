#=================================================
# SRPG::Range
#-------------------------------------------------
# Update : 12/17/2015
#=================================================

module SRPG
  #-----------------------------------------------
  # Range : Class for Range
  #-----------------------------------------------
  class Range
    include Geometry
    include Enumerable
    def initialize(data = Array.new, &block)
      @data = block_given? ? Enumerator.new(&block) : data
    end
    def self.set_enum(object, methname, *args)
      new(object.to_enum(methname,*args))
    end
    #-----------------------------------------------
    # Methods
    #-----------------------------------------------
    def each(*args, &block)
      @data.each(*args,&block)
      self
    end
    def include?(x, y)
      each { |tx, ty| return true if ((x == tx) && (y == ty)) }
      false
    end
    def move(e_x, e_y)
      each { |x, y| yield(x+e_x,y+e_y) }
    end
    def find_min_dis(x, y)
      @data.min { |p1, p2| AI.distance(*p1,x,y)<=>AI.distance(*p2,x,y) }
    end
    def empty?
      each { |x,y| return false }
      return true
    end
    def to_ary
      data = Array.new
      each { |x, y| data.push([x,y]) }
      data
    end
    def to_map(override = true)
      # Get
      meva = get_mxy
      min_x, min_y = meva[2], meva[3]
      dis_x, dis_y = meva[0]-meva[2], meva[1]-meva[3]
      # Set
      map = Map.new(dis_x+1,dis_y+1,0)
      each { |x,y| map[x-min_x,y-min_y] = 1 }
      # Return
      override ? map : [map, min_x, min_y]
    end
    def circumgyrate(trun, ox = 0, oy = 0)
      @data.each { |x, y| cx, cy = cir_point(x-ox,y-oy,trun); yield(cx+ox,cy+oy) }
    end
    def push(array)
      @data = to_ary if @data.is_a?(Enumerator)
      @data.push(array)
      return self
    end
    def flatten
      Range.new(to_ary)
    end
    include Chill
    def get_mxy
      max_x, max_y = @data.peek
      min_x, min_y = @data.peek
      each do |x, y|
        max_x = max(max_x, x)
        max_y = max(max_y, y)
        min_x = min(min_x, x)
        min_y = min(min_y, y)
      end
      # Return
      [max_x, max_y, min_x, min_y]
    end
    #-----------------------------------------------
    # Range Calculate
    #-----------------------------------------------
    # Intersection
    def inter(range)
      data = get_data(range) { |e| !e }
      data.each_key { |x, y| yield(x,y) if (!data[[x,y]]) }
    end
    def uinter(range)
      data = get_data(range) { |e| !e }
      data.each_key { |x, y| yield(x,y) if (data[[x,y]]) }
    end
    # Union
    def union(range)
      data = get_data(range) { true }
      data.each_key { |x,y| yield(x,y) }
    end
    # Difference
    def diff(range)
      data = get_data(range) { false }
      data.each_key { |x, y| yield(x,y) if (data[[x,y]]) }
    end
    # Change Self Method
    def inter!(range)
      initialize(inter(range).flatten)
    end
    def uinter!(range)
      initialize(uinter(range).flatten)
    end
    def union!(range)
      initialize(union(range).flatten)
    end
    def diff!(range)
      initialize(diff(range).flatten)
    end
    private
    def get_data(range)
      data = Hash.new
      each { |x, y| data[[x,y]] = true }
      range.each { |x, y| data[[x,y]] = yield(data[[x,y]]) }
      data
    end
    public
    #-----------------------------------------------
    # Range Relationship
    #-----------------------------------------------
    def equal?(range)
      uinter(range) { return false }
      true
    end
    def in_range?(range)
      inter(range) { return true }
      false
    end
    def out_range?(range)
      inter(range) { return false }
      true
    end
    def all_in_range?(range)
      data = Hash.new
      range.each { |x, y| data[[x,y]] = true }
      each { |x, y| return false if data[[x,y]].nil? }
      true
    end
    def within_range?(range)
      data = Hash.new
      range.each { |x, y| data[[x,y]] = true }
      judge = []
      each do |x, y|
        judge[0] = true if data[[x, y]]
        judge[1] = true if data[[x, y]].nil?
        return true if (judge[0] && judge[1])
      end
      false
    end
    #-----------------------------------------------
    # Enumerator Settler
    #-----------------------------------------------
    class ::Object
      def enum_settler(*meths)
        meths.each do |meth|
          self.class_eval do
            eval %{
              alias old_#{meth} #{meth}
              def #{meth}(*args, &block)
                return SRPG::Range.set_enum(self,:#{meth},*args) if (!block_given?)
                old_#{meth}(*args,&block)
              end
            }
          end
        end
      end
    end
    enum_settler :each, :move, :circumgyrate
    enum_settler :inter, :uinter, :union, :diff
  end
  class WholeRange
    def include?(x, y)
      true
    end
    def move(x, y)
      self
    end
  end
end

module SRPG
  #-----------------------------------------------
  # Range : Static Function Library
  #-----------------------------------------------
  class Range
    #-----------------------------------------------
    # Calculate Range
    #-----------------------------------------------
    def self.post(&block)
      range = SRPG::Range.new([[0,0]])
      return range if (!block)
      range.each(&block)
    end
    def self.whole
      SRPG::WholeRange.new
    end
    def self.range_basic(d, x = 0, y = 0)
      if (d == 0)
        yield(x,y)
      else
        x = x - d
        ps = lambda { |ex, ey| d.times { yield(x+=ex,y+=ey) } }
        ps.call(+1,-1)
        ps.call(+1,+1)
        ps.call(-1,+1)
        ps.call(-1,-1)
      end
    end
    def self.range(d1, d2 = 0, x = 0, y = 0, &block)
      if (d1.is_a?(Array))
        rangea(d1,x,y,&block)
      else
        ranges(d1,d2,x,y,&block)
      end
    end
    def self.ranges(d1, d2 = 0, x = 0, y = 0)
      if (d1 > d2) then t = d1; d1 = d2; d2 = t end
      d1.upto(d2) { |i| range_basic(i,x,y) { |x, y| yield(x,y) } }
    end
    def self.rangea(ds, x = 0, y = 0)
      ds.each { |i| range_basic(i,x,y) { |x, y| yield(x,y) } }
    end
    # Map To Range
    def self.map_to_range(map, eva_x = 0, eva_y = 0)
      map.each_all { |x, y, e| yield(x+eva_x,y+eva_y) if (e == 1) }
    end
    # Match Map Data
    def self.match_map(string, count_p = 1)
      map, px, py = SRPG::Data::MatchMap.matchMap(string,count_p)
      map_to_range(map, -px, -py) { |x, y| yield(x,y) }
    end
    #-----------------------------------------------
    # Enumerator Settler
    #-----------------------------------------------
    class << self
      enum_settler :range, :ranges, :rangea, :map_to_range, :match_map
    end
  end
end

module SRPG
  #-----------------------------------------------
  # Map with Range
  #-----------------------------------------------
  class Map
    def get_with_range(range)
      range.each { |x, y| next if (out?(x,y)); yield(self[x,y],x,y) }
      self
    end
    def set_with_range(range)
      range.each { |x, y| next if (out?(x,y)); self[x,y] = yield(x,y) }
      self
    end
  end
end

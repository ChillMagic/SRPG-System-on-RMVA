#=================================================
# Function Method
#-------------------------------------------------
# Update : 12/17/2015
#=================================================

#-------------------------------------------------
# Class SRPG::Map
#-------------------------------------------------

class SRPG::Map
  include Enumerable
  # Const Variable
  MaxShowSize = 30
  
  # Data Method
  # Safe
  def [](x, y)
    judgeOut(x,y) ? nil : get(x,y)
  end
  def []=(x, y, inc)
    return if judgeError(x,y); set(x,y,inc)
  end
  def point(i)
    [i % @x, i / @x]
  end
  def index(x, y)
    y * @x + x
  end
  # Create & Copy
  def clone
    SRPG::Map.new(@x,@y,@data.clone)
  end
  def new
    SRPG::Map.new(@x,@y,@data.collect{|a|yield(a)})
  end
  def new_with(map)
    data = Array.new
    with(map) { |a,b| data.push(yield(a,b)) }
    SRPG::Map.new(@x,@y,data)
  end
  # Enumerable Basic
  def each
    @data.each { |a| yield(a) }; self
  end
  def each_index
    @y.times { |y| @x.times { |x| yield(x,y) } }; self
  end
  def each_all
    each_index { |x,y| yield(x,y,get(x,y)) }; self
  end
  def with(map)
    (@x*@y).times { |i| yield(@data[i],map.data[i]) }; self
  end
  # Enumerable Set
  def set_with_index
    each_index { |x,y| set(x,y,yield(x,y)) }
  end
  def set_with_all
    each_all { |x,y,e| set(x,y,yield(x,y,e)) }
  end
  # Method
  # Unsafe
  def swap(fx, fy, tx, ty)
    t = get(fx,fy)
    set(fx,fy,get(tx,ty))
    set(tx,ty,t)
  end

protected
  attr_reader :data
  
private
  # Judge Method
  def judgeOut(x, y)
    out?(x,y)
  end
  def judgeError(x, y)
    putError("The Parameter (#{x},#{y}) is Wrong.",x.nil?||y.nil?)
    putError("Point in Map (#{x},#{y}) is Out.",judgeOut(x,y))
  end
end

#-------------------------------------------------
# Class SRPG::Route
#-------------------------------------------------

class SRPG::Route
  # Data Method
  def get_path(x, y)
    return if @waymap[x,y].nil?
    way = @waymap.get(x,y)
    x, y, w = way.x, way.y, way.way
    ways = Array.new
    until w.zero?
      ways.push(w)
      way = @waymap.get(x,y)
      x, y, w = way.x, way.y, way.way
    end
    return ways.reverse
  end
  def get_points
    return SRPG::Range.set_enum(self,__method__) if (!block_given?)
    @movmap.each_all do |x, y, e|
      yield(x,y) if (e >= 0 && e <= MaxMoves)
    end
  end
  # Class Method
  def self.get_route_points(x, y, way)
    data = Array.new
    data.push([x,y])
    way.each do |d|
      x, y = dirMove(d, x, y)
      data.push([x,y])
    end
    data
  end
  def self.dirMove(direction, x, y)
    case direction
      when 0; [x, y]
      when 1; [x, y-1]
      when 2; [x, y+1]
      when 3; [x-1, y]
      when 4; [x+1, y]
    end
  end
end

#-------------------------------------------------
# module SRPG
#-------------------------------------------------

# Using in TEST
module SRPG
  class Map
    # Print
    def printf
      mX, mY = [@x,MaxShowSize].min, [@y,MaxShowSize].min
      mY.times { |y| mX.times { |x| yield(get(x,y)) }; print("\n") }
    end
    def prints
      printf { |e| print(e,' ') }
    end
  end
  class Route::Route_Way
    def to_s
      "[#{x}, #{y}],#{way}"
    end
  end
  def Route.prints(map)  # Using in prints for passmap, movmap & waymap
    map.printf do |tmp|
      if (tmp.nil?)   # waymap
        print('[X, X],- ')
      else
        print(((tmp == Route::MaxMoves + 1) ? 'x' : tmp),' ')
      end
    end
  end
end

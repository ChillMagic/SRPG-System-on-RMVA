#==============================================================================
# SMRC.rb
# Author     : Chill
# Version    : 5.2.0.3  BETA
# Date(V5)   : 2015-06-20 to 2016-02-23
# Description: SRPG on Map of Ruby by Chill.
#==============================================================================

#=================================================
# Basic Method
#=================================================

module SRPG
  #----------------------------------------------------------------------------
  # Class Map
  #----------------------------------------------------------------------------
  class Map
    # Reader
    attr_reader :x, :y
    # Initialize
    def initialize(x, y, data = nil)
      @x, @y = x, y
      # There is Setting Reference.
      @data = data.is_a?(Array) ? data : Array.new(x*y,data)
    end

    # Data Method
    # Unsafe
    def get(x, y)
      @data[y*@x+x]
    end
    def set(x, y, inc)
      @data[y*@x+x] = inc
    end
    # Check
    def out?(x, y)
      x>=@x || y>=@y || x<0 || y<0
    end
  end

  #----------------------------------------------------------------------------
  # Class Route
  #----------------------------------------------------------------------------
  class Route
    # Const Variable
    MaxMoves = 500
    DirMoves = false  # Support OnlyDirMoves.
    # Data Struct
    Route_Way  = Struct.new(:x, :y, :way)
    Route_Data = Struct.new(:x, :y, :move)
    # Reader
    attr_reader :position
    attr_reader :movmap, :waymap
    attr_accessor :dirmap if (DirMoves)
    # Initialize
    def initialize(map, x, y)
      # Set Reference of Map, To Clone this Map, Using 'clone' Method.
      @map = map
      # Set Position to save time, Each Actor with a single Instance.
      putError("Position(#{x},#{y}) was Out.") if (@map.out?(x,y))
      @position = [x, y]
      # Set Route Map.
      @movmap = Map.new(map.x,map.y,MaxMoves + 1)
      @waymap = Map.new(map.x,map.y)
      @dirmap = Map.new(map.x,map.y,0) if (DirMoves)
    end

    # Search
    def search(moves)
      # Record Moves
      return if (moves == -1)
      @moves = (moves < MaxMoves) ? moves : MaxMoves
      putError("We Don't Have a Right Value of Moves.") if (@moves < 0)
      # Create Arrays
      @record = Array.new
      # Set Data
      x, y = *@position
      setData(x,y,x,y,0,0)
      # Start Search
      @record.each do |route|
        x, y = route.x, route.y
        move = route.move + @map.get(x,y)  # Current Point
        next if (move > @moves)
        # judgeSet
        judgeSet(x, y-1, x, y, move, 1) # Up
        judgeSet(x, y+1, x, y, move, 2) # Down
        judgeSet(x-1, y, x, y, move, 3) # Left
        judgeSet(x+1, y, x, y, move, 4) # Right
      end
    end

    private
    # Private Method
    def judgeSet(x, y, rx, ry, move, dir)
      return if (@map.out?(x,y) || move >= @movmap.get(x,y) || @map.get(x,y).zero? || (DirMoves && getDirMove(rx,ry,dir)))
      setData(x,y,rx,ry,move,dir)
    end
    def setData(x, y, rx, ry, move, way)
      @movmap.set(x,y,move)
      @waymap.set(x,y,Route_Way.new(rx,ry,way))
      @record.push(Route_Data.new(x,y,move))
    end
    def getDirMove(x, y, dir)
      i = dir - 1
      num = @dirmap.get(x,y)
      (num - (num >> i << i)) != 0
    end
  end
end

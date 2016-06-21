#=================================================
# SRPG::BattleMap
#-------------------------------------------------
# Update : 01/20/2016
#=================================================

module SRPG
  # Include :
  #   SetterMap
  #   AreaMap
  #   EventMap
  #   TerrainMap
  class BattleMap
    attr_reader :x, :y
    attr_reader :settermap
    def initialize(x, y)
      @x, @y = x, y
    end
    def settermap
      @settermap ||= SetterMap.new(x,y)
    end
  end
end
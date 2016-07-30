#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责战斗的初始化。
#==============================================================================

class SRPG::Battle
  include SRPG
  # Initialize
  def initialize
    # Set Interfaces

    # Init Data
    init_data
  end
  # Init Data
  #  Setter, Map
  def init_data
    # Init PassMap
    @map = init_passmap($game_map)

    @map.get_settermap
  end

  def init_passmap(mapdata)
    BattleMap.new(mapdata)
  end

  def update

  end

end

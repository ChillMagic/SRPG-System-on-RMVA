#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责战斗的初始化。
#==============================================================================

class SRPG::Battle
  include SRPG
  include Config
  # Attr
  attr_reader :sprites, :windows
  attr_reader :map, :data
  # Initialize
  def initialize
    # Set Interfaces
    @sprites = Spriteset_SRPGMap.new
    @windows = Windows_SRPGMap.new
    # Init Data
    init_data
    # Init Show
    init_sprites
    init_windows
    init_player
    # Init Handler
    init_state_handler
    init_window_handler
  end
  # Init Data
  def init_data
    @map    = BattleMap.new($game_map, method(:datafunc), method(:listfunc))
    @data   = BattleData.new(@map)
    @state  = BattleState.new
    @action = BattleAction.new(self)
    @state.set_exist_power([:player,:enemy]) # TODO
  end
  # Init Sprites
  def init_sprites
    @sprites.init_cursor(->(v=nil){self.x(v)},->(v=nil){self.y(v)})
    @sprites.hide_cursor
    @sprites.init_range
  end
  # Init Windows
  def init_windows
    @windows.init_windows
  end
  # Init Player
  def init_player
    $game_player.transparent = true
    $game_player.followers.visible = false
    $game_player.move_speed = CursorSpeed
  end
  def x(v = nil) v.nil? ? $game_player.x : $game_player.x = v end
  def y(v = nil) v.nil? ? $game_player.y : $game_player.y = v end
  # Handle
  def datafunc(datype, id)
    case datype
    when :actor
      $game_actors[id].clone
    when :enemy
      Game_Enemy.new(0,id).clone
    end
  end
  def listfunc(id)
    $game_party.all_members[id-1].clone
  end
end

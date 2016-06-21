#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责战斗的初始化。
#==============================================================================

class SRPG::Battle
  # Attr
  attr_reader :sprites, :windows, :battles  # Import
  attr_reader :event
  # Include
  include SRPG
  include Record
  include MoveKey
  include Config
  # Initialize
  def initialize
    # Set Imports
    @sprites = Spriteset_SRPGMap.new
    @windows = Windows_SRPGMap.new
    @battles = BattleData.new
    @event   = BattleEvent.new(self)
    @process = BattleProcess.new(self)
    # Init Data
    init_data
    # Start
    start
  end
  # Start
  def start
    start_player
    initialize_position
    init_windows
    update_position
    turnto(:battle_start)
  end

  def init_data
    # Init BattleDamage
    if (BattleDamage.get_damagelist.empty?)
      damagelist = BattleDamage.get_damagelist
      damagelist[:item]  = $data_items.collect  { |dat| Data::Damage.new(dat.damage) unless dat.nil? }
      damagelist[:skill] = $data_skills.collect { |dat| Data::Damage.new(dat.damage) unless dat.nil? }
      BattleDamage.set_damagelist(damagelist)
    end
  end
  
  def init_windows
    @windows.init_windows
    set_handlers
  end
  def set_handlers
    set_handler(:move)
    set_handler(:attack)
    set_handler(:skill)
    set_handler(:item)
    set_handler(:status)
    set_handler(:wait)
    set_handler(:overturn)
    set_handler(:confirm_ok,:confirm)
    set_handler(:confirm_cancel,:confirm)
  end
  
  def initialize_position
    battles.datalist[:actor].each do |setter|
      event = get_event(setter)
      id = Data::EventName.get_position(event.event.name)
      next if (id == 0)
      a = setter.data.data
      event.set_graphic(a.character_name,a.character_index)
    end
  end
  # Start
  def start_player
#~     puts(__method__)
    set_record(__method__, [player.x,player.y,player.transparent,player.move_speed,player.followers.visible,player.direction])
    player.transparent = true
    player.followers.visible = false
    player.refresh
  end
  def start_cursor(x, y)
#~     puts(__method__)
    set_player_with_cursor(x, y, true, CursorSpeed, false)
    event.set_cursor(x,y)
    update_position
  end
  def over_cursor
#~     puts(__method__)
#~     set_player_with_cursor(*get_record(:start_player))
  end
  def start_player_turn
#~     puts(__method__)
    min_pos = battles.datalist[:actor].min { |a,b| a.data.id - b.data.id }
    # TODO
    start_cursor(*min_pos.position)
    update_window
  end
  
  #-----------------------------
  # * Player
  #-----------------------------
  def player
    $game_player
  end
  def set_player_with_cursor(x, y, trans, speed, followers_visible, direc = nil)
    player.moveto(x,y)
    player.transparent = trans
    player.move_speed  = speed
    player.followers.visible = followers_visible
    player.set_direction(direc) if direc
    player.refresh
  end
  
  def over
    over_cursor
    @windows.dispose
    @sprites.dispose
  end
end

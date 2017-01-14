#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责战斗画面更新和流程控制。
#==============================================================================

class SRPG::Battle
  #-----------------------------
  # * Main
  #-----------------------------
  # Update
  def update
    begin
      @state.call_function
    rescue => res
      putError(res.to_s)
      puts(res.backtrace)
      raise
    end
    update_windows
    update_call_debug
  end
  #-----------------------------
  # * Start
  #-----------------------------
  def begin_start
    @tempsprite = Data::TempSprite.new(Cache.system("battle-start"))
  end
  def update_start
    @tempsprite.update
    @state.over_update if @tempsprite.over?
  end
  def end_start
    @tempsprite.dispose
  end
  #-----------------------------
  # * Over
  #-----------------------------
  def begin_over
    @tempsprite = Data::TempSprite.new(Cache.system("battle-over"))
  end
  def update_over
    @tempsprite.update
    @state.over_update if @tempsprite.over?
  end
  def end_over
    @tempsprite.dispose
  end
  #-----------------------------
  # * Change
  #-----------------------------
  def begin_change
    @tempsprite = Data::TempSprite.new(Cache.system("turn-#{@state.get_nextstate}"))
  end
  def update_change
    @tempsprite.update
    @state.over_update if @tempsprite.over?
  end
  def end_change
    @tempsprite.dispose
  end
  #-----------------------------
  # * Player
  #-----------------------------
  def begin_player
    # Set PlayerState
    @playerstate = Struct.new(:state,:substate,:sub2state).new
    set_playerstate(:select,:map)
    # Set Sprite
    min_pos = @map.datalist[:actor].min { |a,b| a.data.id - b.data.id }
    @sprites.move_cursor(*min_pos.position)
    @sprites.show_cursor
    @windows.refresh_mapstatus(curr_post, $game_map)
  end
  def update_player
    case @playerstate.state
    when :select
      update_input
      case @playerstate.substate
      when :map
        update_player_select_map
      when :action
        update_player_select_action
      else
        putError("Unfind State(#{@playerstate.state},#{@playerstate.substate}).")
      end
    when :window
      case @playerstate.substate
      when :show
        show_player_window
      when :update
        update_player_window
      else
        putError("Unfind State(#{@playerstate.state},#{@playerstate.substate}).")
      end
    when :doing
      update_player_doing
    else
      putError("Unfind State(#{@playerstate.state},#{@playerstate.substate}).")
    end
    # Check Turn Over
    if @data.turn_over?(:actor)
      @data.turn_over(:actor)
      @state.over_update
    end
  end
  def end_player
    @sprites.hide_cursor
  end
  #-----------------------------
  # * Enemy
  #-----------------------------
  def begin_enemy
  end
  def update_enemy
  end
  def end_enemy
  end
  #-----------------------------
  # * Friend
  #-----------------------------
  def begin_friend
  end
  def update_friend
  end
  def end_friend
  end
  #-----------------------------
  # * Handlers
  #-----------------------------
  # Init State Handler
  def init_state_handler
    set_state_handler(:start)
    set_state_handler(:change)
    set_state_handler(:player)
    set_state_handler(:enemy)
    set_state_handler(:friend)
    set_state_handler(:over)
  end
  def set_state_handler(flag)
    [:begin,:update,:end].each do |state|
      @state.set_handler(flag,state,method("#{state}_#{flag}"))
    end
  end
  #-----------------------------
  # * Update Other
  #-----------------------------
  include MoveKey
  def update_input
    return if ($game_player.moving?)
    move_key.each do |d|
      if Input.press?(d)
        next if @map.out?(*move_with(d,self.x,self.y))
        $game_player.move_with(d)
        break
      end
    end
    @windows.refresh_mapstatus(curr_post, $game_map)
  end
  def update_windows
    @windows.update
  end
  def update_call_debug
    SceneManager.call(Scene_Debug) if ($TEST && Input.press?(:F9))
  end
end

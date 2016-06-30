#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责战斗画面的更新。
#==============================================================================

class SRPG::Battle
  
  # Update
  
  # Main Update State
  # * default  : 0  # Default
  # * forbid   : 1  # Forbid Move Cursor
  
  def update
    case @main_status
    when :battle_start
      result = show_battle_update(:start)
      return unless (result)
      turnto(:show_turn,@battles.battle_first_action)
    when :show_turn
      result = show_turn_update(@argv)
      turnto("#{@argv}_turn".to_sym) if (result)
    when :player_turn
      begin
        result = player_turn_update
      rescue => res
        putError(res.to_s)
      end
      update_input unless ($game_player.moving? || result == :forbid)
      update_window
    when :enemy_turn
      enemy_turn_update
      update_window
    when :battle_over
      result = show_battle_update(@argv)
      return unless (result)
      case @argv
      when :win
        Battle.over(@argv)
      when :lose
        Battle.over(@argv)
      when :interrupt
      end
    end
  end
  
  #-----------------------------
  # * Show Update
  #-----------------------------
  def show_turn_update(type)
    sprite = start_show_turn(type) if (@status == :start)
    show_update(sprite)
  end
  def show_battle_update(type)
    sprite = start_show_battle(type) if (@status == :start)
    show_update(sprite)
  end
  def show_update(sprite = nil)
    case @status
    when :start
      @sprite_show = sprite
      goto(:showing)
    when :showing
      if (@sprite_show.opacity < 255)
        @sprite_show.opacity += 20
      else
        return if (wait(20))
        goto(:hiding)
      end
    when :hiding
      if (@sprite_show.opacity > 0)
        @sprite_show.opacity -= 20
      else
        return true
      end
    end
    return
  end
  def start_show_turn(type)
    sprite = Sprite.new
    sprite.bitmap = Cache.system("turn-#{type}")
    sprite.opacity = 0
    sprite.x = (Graphics.width  - sprite.bitmap.width)  / 2
    sprite.y = (Graphics.height - sprite.bitmap.height) / 2
    return sprite
  end
  def start_show_battle(type)
    sprite = Sprite.new
    sprite.bitmap = Cache.system("battle-#{type}")
    sprite.opacity = 0
    sprite.x = (Graphics.width  - sprite.bitmap.width)  / 2
    sprite.y = (Graphics.height - sprite.bitmap.height) / 2
    return sprite
  end
  
  #-----------------------------
  # * Update Other
  #-----------------------------
  def update_input
    move_key.each do |d|
      if Input.press?(d)
        next if battles.map.out?(*move_with(d,@x,@y))
        $game_player.move_with(d)
        @sprites.cursor.move_with(d)
        break
      end
    end
    update_call_debug
    update_position
    refresh_skill_top
  end
  def update_position
    @x, @y = $game_player.x, $game_player.y
  end
  def update_window
    update_mapstatus
    @windows.update
  end
  def update_mapstatus
    if (@status == :select_move || @status == :select_attack)
      refresh_mapstatus(curr_post.blank? ? active_post : curr_post)
    else
      refresh_mapstatus(curr_post, !curr_post.blank?)
    end
  end
  def update_call_debug
    SceneManager.call(Scene_Debug) if $TEST && Input.press?(:F9)
  end
end

#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分为本类的支持。
#==============================================================================

class SRPG::Battle

  #-----------------------------
  # * Windows
  #-----------------------------
  def set_handler(command, menu = :menu)
    @windows[menu].set_handler(command, method("command_#{command}"))
  end
  def show_menu(flag = nil)
    @windows.show_menu(flag, flag ? active_post : nil)
  end
  def hide_menu
    @windows.hide_menu
  end
  def record_cursor
    @windows.record_cursor
  end
  def decord_cursor
    @windows.decord_cursor
  end
  def change_menu(flag)
    @windows.change_menu(flag)
  end
  def damage_status_show
    @windows.show_damage_status(active_post.data, curr_post.data)
  end
  def damage_status_hide
    @windows.hide_damage_status
  end
  def refresh_mapstatus(setter, show = true)
    @windows.refresh_mapstatus(setter.data, @x, @y, $game_map, show)
  end
  def refresh_mapstatus2(setter)
    @windows.refresh_mapstatus2(setter.data)
  end

  #-----------------------------
  # * Turn Check
  #-----------------------------
  MainStatus = {
      player_turn: [ :actor,  :enemy, :enemy  ],
      enemy_turn:  [ :enemy,  :actor, :friend ],
      other_turn:  [ :friend, nil,    :actor  ],
  }
  MainStatus2 = {
      actor:  :player,
      enemy:  :enemy,
      friend: :other,
  }
  def turn_check(force = false)
    # Check Change Turn
    type = MainStatus[@main_status][0]
    if (battles.turn_over?(type) || force)
      battles.turn_over(type)
      turnto_change
    end
    # Check Battle Over
    result = battles.battle_over?
    turnto(:battle_over,battles.over_flag) if (result)
    return result
  end
  def turnto_change
    return if MainStatus[@main_status].nil?
    type = MainStatus[@main_status][battles.have_friend? ? 2 : 1]
    type = MainStatus2[type]
    turnto(:show_turn,type)
  end
  def over_turn
    turn_check(true)
  end
  
  #-----------------------------
  # * Show/Hide Range
  #-----------------------------
  def show_range(setter, type)
    intype = battles.get_intype(setter,type)
    event.show_range(setter,intype)
  end
  def show_ranges(*datas)
    event.show_ranges(*datas)
  end
  def hide_range(move_cursor = false)
    event.hide_range
    event.move_cursor(active_post) if (move_cursor)
  end

  #-----------------------------
  # * Adjust
  #-----------------------------
  def adjust_select_cursor(condition)
    data = battles.datalist[:actor].data
    id = data.index(curr_post)
    id = 0 if id.nil?
    id = (id + (condition ? +1 : -1)) % data.size
    event.move_cursor(data[id])
  end
  def adjust_direction
    dir = active_event.direction
    dir = battles.attack_direction(active_post, curr_post, dir)
    active_event.set_direction(dir)
  end
end

#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责玩家的操作。
# ==============================================================================

class SRPG::Battle
  #-----------------------------
  # * Player Turn Update
  #-----------------------------
  def update_player_select_map
    if (input?(:C))
      if (@data.can_control?(curr_post))
        set_active_post
        flag = :action
      else
        clear_active_post
        flag = :total
      end
      record_playerstate
      set_playerstate(:window,:show,flag)
    end
  end
  def update_player_select_action
    # Set Dir
    event = @data.get_event(active_post)
    dir = @data.action_direction(active_post,curr_post,event.direction)
    event.set_direction(dir)
    # Get Input
    if (input?(:C))
      @action.set_target(curr_post)
      if (@action.do_check)
        p @action.get_action
        @action.do_start
        set_playerstate(:doing)
      end
    elsif (input?(:B))
      # Recover Dir
      event = @data.get_event(active_post)
      event.set_direction(@recdir)
      # Set
      set_playerstate(:window,:show,:action)
      @sprites.hide_range
      @sprites.recover_cursor
      @windows.refresh_mapstatus(active_post, $game_map, true)
    end
  end
  def show_player_window
    @sprites.move_cursor(*active_post.position) if active_post
    @windows.show_menu(@playerstate.sub2state,active_post)
    set_playersubstate(:update)
    @sprites.record_cursor
    @windows.recover_cursor
  end
  def update_player_window
    if (input?(:B))
      case @playerstate.sub2state
      when :total
        set_playerstate(:select,:map)
        @windows.hide_menu
      when :action
        unless @action.done? && @action.do_cancel
          set_playerstate(:select,:map)
        end
        @windows.hide_menu
      when :confirm
        command_confirm_cancel
      end
    end
  end
  def update_player_doing
    if (@action.doing)
      @sprites.hide_range
      set_playerstate(:window,:show,:action)
    end
  end
  # PlayerState
  def set_playerstate(state, substate = nil, sub2state = nil)
    @playerstate.state = state
    @playerstate.substate = substate
    @playerstate.sub2state = sub2state
    print_playerstate
  end
  def set_playersubstate(substate)
    @playerstate.substate = substate
    print_playerstate
  end
  def set_playersub2state(substate)
    @playerstate.sub2state = substate
    print_playerstate
  end
  def record_playerstate
    @recplayerstate ||= Array.new
    @recplayerstate.push(@playerstate.clone)
  end
  def recover_playerstate
    @playerstate = @recplayerstate.pop
    print_playerstate
  end
  def reset_playerstate
    @recplayerstate = Array.new
    print_playerstate
  end
  def print_playerstate
    puts("PlayState: " + @playerstate.to_a.join(", ")) if (Battle.print_playerstatelog?)
  end
  #-----------------------------
  # * Commands
  #-----------------------------
  def command_move
    do_command_action(:move,true)
  end
  def command_attack
    do_command_action(:attack,true)
  end
  def command_skill
    do_command_action(:skill,true,5)
  end
  def command_item
    do_command_action(:item,true,5)
  end
  def command_status
  end
  def command_wait
    active_post.status.wait
    set_playerstate(:select,:map)
    @windows.hide_menu
    @action.clear_action
  end
  def command_confirm_ok
    @state.over_update
    @windows.hide_confirm
    @windows.hide_menu
  end
  def command_confirm_cancel
    @windows.hide_confirm
    recover_playerstate
  end
  def command_overturn
    @windows.show_confirm
    record_playerstate
    set_playersub2state(:confirm)
  end
  def do_command_action(type, showrange, id = nil)
    # Record Dir
    event = @data.get_event(active_post)
    @recdir = event.direction
    # Set
    set_playerstate(:select,:action,type)
    @action.set_action(type,active_post)
    @action.set_data(id)
    @sprites.show_range(*@data.get_show_range(type,active_post,id)) if showrange
    @windows.record_cursor
    @windows.hide_menu
  end
  #-----------------------------
  # * Handlers
  #-----------------------------
  # Init State Handler
  def init_window_handler
    set_window_handler(:move)
    set_window_handler(:attack)
    set_window_handler(:skill)
    set_window_handler(:item)
    set_window_handler(:status)
    set_window_handler(:wait)
    set_window_handler(:overturn)
    set_window_handler(:confirm_ok,:confirm)
    set_window_handler(:confirm_cancel,:confirm)
  end
  def set_window_handler(command, menu = :menu)
    @windows[menu].set_handler(command, method("command_#{command}"))
  end
end

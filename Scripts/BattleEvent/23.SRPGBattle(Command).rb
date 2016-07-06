#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责处理战斗的操作。
#==============================================================================

class SRPG::Battle

  # Player Turn Update

  def player_turn_update
    case @status
    # Start
    when :start
      start_player_turn
      goto(:select)
    # Select
    when :select
      turn_check
      if (input?(:C))
        if (battles.can_control?(curr_post))
          set_active_post
          goto(ShowMoveFirst ? :select_move : :select_action)
        else
          change_menu(:select)
          goto(:show_menu)
        end
      end
      if (input?(:B))
        goto(:show_move) if battles.is_battler?(curr_post)
      end
      if (input?(:A) && Battle.infinite_action?)
        battles.reset_status
      end
      if (input?(:X))
        turnto(:battle_over,:win)
      end
      if (input?(:L) || input?(:R))
        adjust_select_cursor(input?(:R))
      end
    # Show Menu
    when :show_menu
      show_menu
      if (input?(:B))
        hide_menu
        goto(:select)
      end
      return :forbid
    # Show Confirm
    when :show_confirm
      if (input?(:B))
        command_confirm_cancel
        goto(:show_menu)
      end
      return :forbid
    # Select Action Menu
    when :select_action
      return goto(:select) if (!battles.show_action_menu?(active_post))
      show_menu(:action)
      if (input?(:B))
        hide_menu
        if (active_status.can_unmove?)
          event_move_recover
          goto(:select_move)
        else
          goto(:select)
        end
      end
      return :forbid
    # Select Object Begin
    when :select_object
      actions.show_range
      goto(:select_object_update)
    # Select Object Update
    when :select_object_update
      actions.update_range
      if (input?(:C))
        actions.do_check
      elsif (input?(:B))
        actions.hide_range
      end
    # Select Confirm
    when :select_confirm
      if (!AttackAfterOK || input?(:C))
        actions.do_confirm
      elsif (input?(:B))
        damage_status_hide
        # hide_range
        goto(:select_object)
      end
      return :forbid
    # Doing
    when :doing
      return :forbid if (event.doing?)
      actions.do_over
    #------------------------------------
    # Select Move
    when :select_move
      actions.set_action(:move, active_post)
      goto(:select_object)
    # Select Attack
    when :select_attack
      actions.set_action(:attack, active_post)
      goto(:select_object)
    # Select Skill
    when :select_skill
      actions.set_action(:skill, active_post)
      actions.set_data(5)
      goto(:select_object)
    # Select Item
    when :select_item
      actions.set_action(:item, active_post)
      actions.set_data(5)
      goto(:select_object)
    #------------------------------------
    # Select Wait Direction
    when :select_direction
      if (Battle.select_direct?)
        # TODO
        if (input?(:C))
          goto(:select)
        elsif (Input.dir4 > 0)
          active_event.set_direction(Input.dir4)
        end
      else
        goto(:select)
      end
      return :forbid
    # Show Move Range
    when :show_move
      goto(:select)
      return :default
      # TODO
      show_range(curr_post,:move)
      if (input?(:C))
        hide_range
        if (battles.is_controled?(curr_post) && curr_status.action?)
          set_active_post
          goto(ShowMoveFirst ? :select_move : :select_action)
        else
          goto(:select)
        end
      elsif (input?(:B))
        if (battles.is_battler?(curr_post))
          change_record(:set_active_post,true)
          show_range(curr_post,:move,true)
        else
          hide_range
          goto(:select)
        end
      end
    end
    return :default
  end

  #-----------------------------
  # ! Command Set !
  #-----------------------------
  def command_move
    hide_menu
    goto(:select_move)
  end
  def command_attack
    hide_menu
    change_record(:move_attack, false)
    record_cursor
    record_direction
    goto(:select_attack)
  end
  def command_skill
    hide_menu
    record_cursor
    record_direction
    goto(:select_skill)
  end
  def command_item
    hide_menu
    record_cursor
  end
  def command_status
    hide_menu
    record_cursor
    SceneManager.call(Scene_Status2)
  end
  def command_wait
    hide_menu
    active_status.wait
    del_record(:move_position)
    del_record(:attk_direction)
    del_record(:move_direction)
    goto(:select_direction)
  end
  def command_confirm_ok
    @windows.hide_confirm
    hide_menu
    over_turn
  end
  def command_confirm_cancel
    @windows.hide_confirm
    goto(:show_menu)
  end
  def command_overturn
    @windows.show_confirm
    goto(:show_confirm)
  end
  #-----------------------------
  # ! Command Set !
  #-----------------------------

  #-----------------------------
  # ! Event Set !
  #-----------------------------
  # From ActivePost to a setter.
  def event_move_start(x, y)
    if (event_move_start_basic(active_post,x,y))
      change_record(:move_attack,false)
      set_record(:move_position,  active_post.position)
      set_record(:move_direction, active_event.direction)
      return true
    elsif (point = battles.can_move_attack?(active_post,x,y))
      change_record(:move_attack,true)
      set_record(:move_position,  active_post.position)
      set_record(:move_direction, active_event.direction)
      record_direction
      return event_move_start_basic(active_post,*point)
    end
    return false
  end
  def event_move_start_basic(setter, x, y)
    return false unless (battles.can_move?(setter,x,y))
    event.move(setter,x,y) if (battles.get_setter(x,y).blank?)
    return true
  end
  def event_move_recover
    active_post.status.unmove
    x, y = get_record(:move_position)
    if (active_post.position != [x, y])
      active_event.set_direction(get_record(:move_direction))
      active_post.moveTo(x,y)
      active_event.moveto(x,y)
    end
  end
  #-----------------------------
  # ! Event Set !
  #-----------------------------
end

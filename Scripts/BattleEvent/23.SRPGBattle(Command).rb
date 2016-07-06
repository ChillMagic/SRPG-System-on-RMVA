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
    # Select Object
    when :select_object
      event_show_range_real
      if (input?(:C))
        event_do_check
        # return :forbid
      elsif (input?(:B))
        event_hide_range_real
        # return :forbid
      end
    # Select Confirm
    when :select_confirm
      if (!AttackAfterOK || input?(:C))
        event_do_confirm
      elsif (input?(:B))
        damage_status_hide
        # hide_range
        goto(:select_object)
      end
      return :forbid
    # Doing
    when :doing
      return :forbid if (event.doing?)
      event_do_over
    #------------------------------------
    # Select Move
    when :select_move
      actions.set_action(:move, active_post)
      p actions.get_action
      goto(:select_object)
    # Select Attack
    when :select_attack
      actions.set_action(:attack, active_post)
      p actions.get_action
      goto(:select_object)
    # Select Skill
    when :select_skill
      actions.set_action(:skill, active_post)
      actions.set_data(5)
      p actions.get_action
      goto(:select_object)
    # Select Item
    when :select_item
      actions.set_action(:item, active_post)
      actions.set_data(5)
      p actions.get_action
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
    set_record(:attk_direction, active_event.direction)
    goto(:select_attack)
  end
  def command_skill
    hide_menu
    record_cursor
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
  def event_show_range_real
    case actions.get_type
    when :move
      show_range(active_post,:move)
    when :attack
      show_range(active_post,:attack_opt)
      adjust_direction
    when :skill
      @select_skill = true
      show_ranges([active_post,:skill_opt],[curr_post,:skill_elt])
      adjust_direction
    end
  end
  def event_hide_range_real
    case actions.get_type
    when :move
      hide_range(true)
      goto(ShowMoveFirst ? :select : :select_action)
    when :attack
      active_event.set_direction(get_record(:attk_direction))
      if (get_record(:move_attack))
        event_move_recover
        hide_range
        goto(:select_move)
      else
        hide_range(true)
        goto(:select_action)
      end
    when :skill
      # TODO
      @select_skill = false
      hide_range(true)
      goto(:select_action)
    end
  end
  def event_do_check
    actions.set_target(curr_post)
    case actions.get_type
    when :move
      result = event_move_start(*curr_post.position)
      if (result)
        hide_range
        goto(:doing)
      end
    when :attack
      result = battles.check_action(actions.get_action)
      if (result)
        damage_status_show
        goto(:select_confirm)
      end
    when :skill
      result = battles.check_action(actions.get_action)
      if (result)
        @select_skill = false
        hide_range
        damage_status_show
        decord_cursor
        goto(:select_confirm)
      end
    end
  end
  def event_do_start
    # TODO
    case actions.get_type
    when :attack
      event.attack(active_post,curr_post)
    when :skill
      event.attack(active_post,curr_post)
    end
  end
  def event_do_confirm
    case actions.get_type
    when :move
    when :attack, :skill
      hide_range
      event_do_start
      goto(:doing)
    end
  end
  def event_do_over
    case actions.get_type
    when :move
      goto(get_record(:move_attack) ? :select_attack : :select_action)
    when :attack
      damage_status_hide
      goto(:select_action)
    when :skill
      damage_status_hide
      goto(:select_action)
    end
  end
  #-------------------------
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
      set_record(:attk_direction, active_event.direction)
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

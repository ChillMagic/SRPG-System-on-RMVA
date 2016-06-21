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
        data = @battles.datalist[:actor].data
        id = data.index(@battles.map[@x,@y])
        id = 0 if id.nil?
        if (id)
          jud = input?(:R)
          id = (id + (jud ? +1 : -1)) % data.size
          event.move_cursor(data[id])
        end
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
    # Select Move
    when :select_move
      show_range(active_post,:move)
      if (input?(:C))
        if (event_move_start(*curr_post.position))
          hide_range
          goto(:moving)
        end
      elsif (input?(:B))
        hide_range(true)
        goto(ShowMoveFirst ? :select : :select_action)
      end
    # Select Attack
    when :select_attack
      show_range(active_post, :attack_opt)
      active_event.set_direction(battles.attack_direction(active_post, curr_post, active_event.direction))
      if (input?(:C))
        if (event_attack_check(curr_post))
#~           hide_range
          damage_status_show
          goto(:attack_confirm)
#~           goto(:attacking)
          return :forbid
        end
      elsif (input?(:B))
        active_event.set_direction(get_record(:attk_direction))
        if (get_record(:move_attack))
          event_move_recover
          hide_range
          goto(:select_move)
        else
          hide_range(true)
          goto(:select_action)
        end
      end
    # Select Skill
    when :select_skill
      event.show_ranges([active_post, :skill_opt],[curr_post, :skill_elt])
      @select_skill = true
      if (input?(:C))
        if (true)
          @select_skill = false
          @sprites.ranges.clear
          hide_range(true)
        end
        return :forbid
      elsif (input?(:B))
        @select_skill = false
        @sprites.ranges.clear
        hide_range(true)
        goto(:select_action)
        return
      end
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
    # Attack Confirm
    when :attack_confirm
#~       if (input?(:C))
        hide_range
        event_attack_start(curr_post)
        goto(:attacking)
#~       elsif (input?(:B))
#~         damage_status_hide
#~         goto(:select_attack)
#~       end
      return :forbid
    # Moving
    when :moving
      return :forbid if (event.doing?)
      goto(get_record(:move_attack) ? :select_attack : :select_action)
    # Attacking
    when :attacking
      return :forbid if (event.doing?)
      event_attack_over
      goto(:select_action)
    # Show Move Range
    when :show_move
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
  #-------------------------
  def event_attack_check(setter)
    battles.can_attack?(active_post,setter)
  end
  def event_attack_start(setter)
    # TODO
    event.attack(active_post,setter)
  end
  def event_attack_over
    # TODO
    damage_status_hide
  end
  #-----------------------------
  # ! Event Set !
  #-----------------------------
end

#==============================================================================
# ■ Windows_SRPGMap
#------------------------------------------------------------------------------
# 　管理窗口的组。本部分为各种窗口显示函数的包装。
#==============================================================================

class Windows_SRPGMap
  # Total
  TotalWindows = [
      :menu,
      :mapstatus,
      :mapstatus2,
      :confirm
  ]
  def init_windows
    TotalWindows.each { |name| self[name] }
  end

  # Menu
  def show_menu(flag = nil, setter = nil)
    w = @windows[:menu]
    return if (w.visible)
    if (flag.nil?)
      w.show
      return
    end
    case flag
    when :action
      w.set_command_list(menu_action_command_list(setter))
    when :total
      w.set_command_list(menu_total_command_list)
    else
      putError("Unfind the flag(#{flag}) for show_menu.")
    end
    w.select(0)
    w.refresh
    w.show
  end
  def hide_menu
    w = @windows[:menu]
    w.hide if (w.visible)
  end
  def record_cursor
    w = @windows[:menu]
    w.record_cursor
  end
  def recover_cursor
    w = @windows[:menu]
    w.recover_cursor
  end
  def change_menu(flag)
    w = @windows[:menu]
    w.change_status(flag)
  end
  def set_menu_flag(flag)
    w = @windows[:menu]
    w.change_status(flag)
  end
  # MapStatus
  def refresh_mapstatus(setter, map, force = false)
    w = @windows[:mapstatus]
    data = setter.data
    return if (data == @record_battler)
    @record_battler = data
    return w.hide if (data.nil? && !force)
    w.refresh(data)
    w.set_post((setter.y <= map.height - w.total_height) ? :d : :u)
    w.visible = true
  end
  def refresh_mapstatus2(data)
    w = @windows[:mapstatus2]
    w.refresh(data)
  end

  def show_damage_status(data)
    w = @windows[:mapstatus]
    w.refresh(data)
    w.show
  end

  # Damage Status
  def show_damage_statusX(adata, bdata)
    w1 = @windows[:mapstatus]
    w2 = @windows[:mapstatus2]
    w2.show
    w1.record_post
    w1.set_post(:dl)
    w2.set_post(:dr)
    w1.refresh(adata)
    w2.refresh(bdata)
  end
  def hide_damage_statusX
    w1 = @windows[:mapstatus]
    w2 = @windows[:mapstatus2]
    w1.recover_post
    w2.hide
  end
  # Confirm
  def show_confirm
    w1 = @windows[:menu]
    w2 = @windows[:confirm]
    w1.active = false
    w2.show
    w2.active = true
  end
  def hide_confirm
    w1 = @windows[:menu]
    w2 = @windows[:confirm]
    w2.hide
    w1.refresh
    w1.show
  end

  # Menu
  def menu_total_command_list
    [
        ["回合结束", :overturn],
    ]
  end
  def menu_action_command_list(setter)
    [
        ["移动", :move, !setter.status.moved],
        ["攻击", :attack, !setter.status.acted],
        ["技能", :skill, !setter.status.acted],
        ["物品", :item, !setter.status.acted],
        ["状态", :status, !setter.status.acted],
        ["待机", :wait]
    ]
  end
end

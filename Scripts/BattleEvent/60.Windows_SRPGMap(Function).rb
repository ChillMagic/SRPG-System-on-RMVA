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
    w.change_status(flag) if flag
    w.select_adjust
    w.show
    if (flag == :action)
      w.refresh(setter)
    end
  end
  def hide_menu
    w = @windows[:menu]
    w.hide if (w.visible)
  end
  def record_cursor
    w = @windows[:menu]
    w.record_cursor
  end
  def decord_cursor
    w = @windows[:menu]
    w.decord_cursor
  end
  def change_menu(flag)
    w = @windows[:menu]
    w.change_status(flag)
  end
  # MapStatus
  def refresh_mapstatus(data, cur_x, cur_y, map, show = true)
    w = @windows[:mapstatus]
    return if (data == @record_battler)
    @record_battler = data
    w.refresh(data)
    w.set_post((cur_y <= map.height - w.total_height) ? :d : :u)
    w.visible = show
  end
  def refresh_mapstatus2(data)
    w = @windows[:mapstatus2]
    w.refresh(data)
  end

  # Damage Status
  def show_damage_status(adata, bdata)
    w1 = @windows[:mapstatus]
    w2 = @windows[:mapstatus2]
    w2.show
    w1.record_post
    w1.set_post(:dl)
    w2.set_post(:dr)
    w1.refresh(adata)
    w2.refresh(bdata)
  end
  def hide_damage_status
    w1 = @windows[:mapstatus]
    w2 = @windows[:mapstatus2]
    w1.recover_post
    w2.hide
  end
  def show_confirm
    w1 = @windows[:menu]
    w2 = @windows[:confirm]
    w2.select_adjust
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
end

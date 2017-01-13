#==============================================================================
# ■ Spriteset_SRPGMap
#------------------------------------------------------------------------------
#   管理地图元素的精灵组。本部分为各种精灵显示函数的包装。
#==============================================================================

class Spriteset_SRPGMap
  # Cursor
  def init_cursor(fx, fy)
    @binding ||= Hash.new
    @binding[:cursor_x] = fx
    @binding[:cursor_y] = fy
    @cursor = Spriteset_Cursor.new(@viewport,fx.call,fy.call)
    @sprites.push(@cursor)
    @cursor.visible = false
  end
  def move_cursor(x, y)
    @binding[:cursor_x].call(x)
    @binding[:cursor_y].call(y)
  end
  def show_cursor
    @cursor.visible = true
  end
  def hide_cursor
    @cursor.visible = false
  end
  def record_cursor
    @record_x = @binding[:cursor_x].call
    @record_y = @binding[:cursor_y].call
  end
  def recover_cursor
    @binding[:cursor_x].call(@record_x)
    @binding[:cursor_y].call(@record_y)
  end
  # Range
  def init_range
    @range = Spriteset_Ranges.new(@viewport)
    @sprites.push(@range)
    @range.hide
  end
  def set_range(fbottom, ftop = nil)
    @binding ||= Hash.new
    @binding[:range_bottom] = fbottom
    @binding[:range_top] = ftop ? ftop : ->{ return [ SRPG::Range.new ] }
  end
  def show_range(fbottom = nil, ftop = nil)
    set_range(fbottom, ftop) if fbottom
    @range.clear
    @range.push(*@binding[:range_bottom].call)
    @range.push(*@binding[:range_top].call)
    @range.show
  end
  def hide_range
    @range.hide
  end
  # Update
  def update
    update_cursor
    update_range
    super
  end
  def update_cursor
    @cursor.move_to(@binding[:cursor_x].call,@binding[:cursor_y].call) if @cursor.visible
  end
  def update_range
    @range.reset_top(*@binding[:range_top].call) if @range.visible
  end
end

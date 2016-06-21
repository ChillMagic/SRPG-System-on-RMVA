#==============================================================================
# ■ Spriteset_SRPGMap
#------------------------------------------------------------------------------
#   管理地图元素的精灵组。本部分为各种精灵显示函数的包装。
#==============================================================================

class Spriteset_SRPGMap
  # Create
  def new(flag, *args)
    case flag
    when :range;  sprite = Spriteset_Ranges.new(@viewport)
    when :cursor; sprite = Spriteset_Cursor.new(@viewport,*args)
    end
    @sprites.push(sprite) if (sprite)
    return sprite
  end

  # Range
  def ranges
    return @ranges if @ranges
    @ranges = new(:range)
    return @ranges
  end
  def hide_range
    ranges.clear
    ranges.hide
  end
  def push_range(datas, refresh = true)
    if (refresh)
      ranges.sets(datas)
      ranges.show
    else
      ranges.push_sets(datas)
    end
  end

  # Cursor
  def set_cursor(x = 0, y = 0, kind = 0)
    if (@cursor)
      @cursor.move_to(x, y)
      @cursor.change_kind(kind)
    else
      @cursor = new(:cursor,x,y,kind)
    end
  end
  def move_cursor(x, y)
    # TODO
    set_cursor(x,y)
  end
  def cursor
    return putError("Unset Cursor.") unless @cursor
    return @cursor
  end
  
  # Route
  def set_route(x, y, way)
    return putError("Seted Route.") if @route
    @route = Spriteset_Route.new(@viewport,x,y,way)
    @sprites.push(@route)
  end
  def route
    return putError("Unset Route.") unless @route
    return @route
  end
end

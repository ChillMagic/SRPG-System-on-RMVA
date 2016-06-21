#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分对Command编写提供便利的支持。
#==============================================================================

class SRPG::Battle

  # Current & Active Post
  
  def curr_post
    battles.map[@x,@y]
  end
  def active_post
    rec = get_record(:active_post)
    putError("None ActivePost.") unless rec
    rec ? rec : curr_post
  end
  def set_active_post
    set_record(:active_post,curr_post)
  end
  
  def get_event(setter)
    $game_map.events[setter.id]
  end
  def active_event
    get_event(active_post)
  end
  def curr_event
    get_event(curr_post)
  end
  def active_status
    active_post.status
  end
  def curr_status
    curr_post.status
  end

  # Flow Control
  
  def goto(status)
    puts(status) if Battle.print_gotolog?
    @status = status
  end
  def turnto(main_status, argv = nil)
    puts(main_status) if Battle.print_turntolog?
    @main_status = main_status
    @argv = argv
    goto(:start)
  end
  # Usage:
  # * return if (wait(duration))
  def wait(duration)
    first_set_record(:wait,0)
    change_record(:wait,get_record(:wait)+1)
    return true if (get_record(:wait) <= duration)
    del_record(:wait)
    return false
  end
  
  # Input Inquiry

  def input?(input)
    # Input.repeat?, Input.trigger?, Input.press?
    Input.trigger?(input)
  end

end

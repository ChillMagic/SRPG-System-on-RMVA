#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分对流程控制的编写提供便利的支持。
#==============================================================================

class SRPG::Battle

  # Current & Active Post

  def curr_post
    @map[self.x,self.y]
  end
  def active_post
    @active_post
  end
  def set_active_post
    @active_post = curr_post
  end
  def clear_active_post
    @active_post = nil
  end

  # Input Inquiry

  def input?(input)
    # Input.repeat?, Input.trigger?, Input.press?
    Input.trigger?(input)
  end
end

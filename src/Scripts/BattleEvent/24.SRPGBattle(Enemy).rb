#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的实例类。本部分负责处理战斗的操作。
#==============================================================================

class SRPG::Battle
  
  # Enemy Turn Update
  
  def enemy_turn_update
    # TODO
    case @status
    when :start
      @actionlist = battles.datalist[:enemy].to_list
      goto(:doing)
    when :doing
      return :forbid if (event.interpreter_doing?)
      return goto(:check) if @actionlist.empty?
      enemy_action
      @actionlist.next(true)
    when :check
      over_turn
    end
    return :default
  end
  def enemy_action
    setter = @actionlist.first
    p battles.get_attack_list(setter,setter.data.view)
    result = enemy_attack_action(setter)
    enemy_search_action(setter) if (!result)
  end
  def enemy_attack_action(setter)
    view = setter.data.view
    view = setter.data.move if view.nil?
    return if view.nil? || view.zero?
    x, y, target = enemy_get_attack_point(setter)
    return false if y.nil?
    event.interpreter_add([:move,[setter,x,y]])
    event.interpreter_add([:attack,[setter,target]])
  end
  def enemy_search_action(setter)
    view = setter.data.view
    return if view.nil? || view.zero?
    x, y = enemy_get_attack_point(setter,view)
    return false if y.nil?
    event.interpreter_add([:move,[setter,x,y,view]])
  end
  def enemy_get_attack_point(setter, view = nil)
    target = battles.get_attack_list(setter,view).first
    return if target.nil?
    x, y = battles.get_attack_move_point(setter,*target.position,view)
    return [x, y, target]
  end
end

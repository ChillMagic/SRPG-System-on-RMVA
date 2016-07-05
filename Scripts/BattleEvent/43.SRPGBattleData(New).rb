#==============================================================================
# ■ SRPG::BattleData
#------------------------------------------------------------------------------
# 　SRPG系统战斗的数据支持类。
#==============================================================================

module SRPG
  class BattleData
    # Range -> Battlers
    def get_battlers(range, types)
      range.select { |x,y| types.include?(@map[x,y].type) }.collect { |x,y| @map[x,y] }
    end
    # Check
    #  action : SelectAction
    def check_action(action)
      p action
      type = action.type
      initiator = action.initiator
      target = action.target
      data = action.data
      case type
      when :attack
        baseitem = initiator.data.get_attack_data
        func = lambda { |x, y| can_damage?(initiator, @map[x,y]) }
      when :skill
        id = data
        baseitem = initiator.data.get_skill_data(id)
        func = lambda { |x, y| can_damage?(initiator, @map[x,y]) } # 'can_damage?'
      when :item
        id = data
        baseitem = initiator.data.get_item_data(id)
        func = lambda { |x, y| f(initiator, @map[x,y]) }
      else
        return putError("Not find Action(#{type}).")
      end
      useable_range = baseitem.range(initiator.position,target.position)
      return check_range(useable_range,*target.position,func)
    end
    def check_range(useable_range, x, y, func)
      return false unless useable_range.check_in(x, y)
      return false unless useable_range.check_each { |x, y| func.call(x,y) }
      return true
    end
  end
end

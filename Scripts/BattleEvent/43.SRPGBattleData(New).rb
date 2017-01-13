#==============================================================================
# ■ SRPG::BattleData
#------------------------------------------------------------------------------
# 　SRPG系统战斗的数据支持类。
#==============================================================================

module SRPG
  class BattleData
    # Range -> Battlers
    # def get_battlers(range, types)
      # range.select { |x,y| types.include?(@map[x,y].type) }.collect { |x,y| @map[x,y] }
    # end
    # Check
    #  action : SelectAction
    def check_action(action)
      type = action.type
      initiator = action.initiator
      target = action.target
      data = action.data
      case type
      when :move
        args = [action.initiator, *action.target.position]
        if (can_move?(*args))
          action.set_data([false,action.target.position])
          return true
        elsif (point = can_move_attack?(*args))
          action.set_data([true,point])
          return true
        end
        return false
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
      moved_range = baseitem.useable_range.moved_range(initiator.position,target.position)
      return check_range(moved_range,*target.position,func)
    end
    def check_range(moved_range, x, y, func)
      return false unless moved_range.check_in(x, y)
      return false unless moved_range.check_each { |x, y| func.call(x,y) }
      return true
    end
    #
    # def get_range_from_action(action)
    #   case get_type
    #   when :move
    #     return UseableRange.new(battles.get_range(:m, action.get_initiator), nil)
    #   when :attack
    #     action.get_initiator.data.get_attack_data.range(action.get_initiator, action.get_target)
    #   when :skill
    #   end
    # end
  end
end

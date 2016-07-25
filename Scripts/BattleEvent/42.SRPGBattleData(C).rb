#==============================================================================
# ■ SRPG::BattleData
#------------------------------------------------------------------------------
# 　SRPG系统战斗的数据支持类。本部分负责处理计算问题。
#==============================================================================

module SRPG
  class BattleData
    #-------------------------
    # * Action: Battle Basic
    #-------------------------
    def attack(sa, sb)
      call_damage(:attack, sa.data, sb.data)
    end
    def call_damage(type, a, b, id = 0)
      return putError("Error in Nil Batter.") if (a.nil? || b.nil?)
      baseitem = (type == :attack) ? a.get_attack_data : DataManager.get(type,id)
      result = a.damage_evaluate_basic(type, b, baseitem)
      return putError("Error in Battle Result.") if (result.nil?)
      b.set_damage(result.damage)
      return b.dead?
    end
    def use_skill_real(id, setter, target, func)
      use_baseitem_real(:skill, id, setter, target, func)
    end
    def use_baseitem_real(type, id, setter, target, func)
      baseitem = DataManager.get(type,id)
      range = baseitem.useable_range.get_range(:elected,target.position)
      dead = []
      range.each do |x, y|
        tar = @map[x, y]
        next if tar.data.nil?
        func.call(tar)
        result = call_damage(type, setter.data, tar.data, id)
        dead.push(tar) if (result)
      end
      dead
    end
    #-------------------------
    # * Show
    #-------------------------
    # Attack Direction
    #   (dx, dy)
    #   (<, <), (=, <), (>, <)
    #   (<, =), (=, =), (>, =)
    #   (<, >), (=, >), (>, >)
    def attack_direction(cur_pos, tar_pos, cur_dir)
      c, t = cur_pos.position, tar_pos.position
      dx, dy = (t[0] - c[0]), (t[1] - c[1])
      dir = DirR2S[cur_dir]
      if (dx == 0 && dy != 0)
        dir = (dy > 0) ? :DOWN : :UP
      elsif (dy == 0 && dx != 0)
        dir = (dx > 0) ? :RIGHT : :LEFT
      elsif (dy < 0 && dir == :DOWN)
        dir = :UP
      elsif (dy > 0 && dir == :UP)
        dir = :DOWN
      elsif (dx < 0 && dir == :RIGHT)
        dir = :LEFT
      elsif (dx > 0 && dir == :LEFT)
        dir = :RIGHT
      end
      return DirS2R[dir]
    end
  end
end

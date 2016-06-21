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
      return use_skill(sa,sb)
    end
    def use_skill(sa, sb, skill_id = 0)
      a, b = sa.data, sb.data
      return putError("Error in Nil Batter.") if (a.nil? || b.nil?)
      return putError("Error in Nil Skill ID.") if (skill_id.nil?)
      # TODO
      type = (skill_id > 0) ? :skill : :attack
      skill = nil ###
      result = a.damage_evaluate_basic(type, b)
      return putError("Error in Battle Result.") if (result.nil?)
      b.set_damage(result.damage)
      return b.dead?
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

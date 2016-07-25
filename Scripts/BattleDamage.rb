#=================================================
# SRPG::BattleDamage
#-------------------------------------------------
# Update : 06/21/2016
#=================================================

module SRPG
  module BattleDamage
    # Get Damage
    def self.get_damage(a, b, damagedata)
      basdam = AI.make_skill_damage(a, b, DataManager.get_data(:variables), damagedata.formula)
      vardam = damagedata.variance
      return basdam + basdam * AI.rand(-vardam, vardam) / 100
    end
    # Damage Evaluate
    def self.damage_evaluate(type, b1, b2, baseitem)
      result = AI::DamageEvaluate.new(0, 0)
      case type
      when :attack, :skill, :item
        damage = get_damage(b1, b2, baseitem.damage)
        result.damage = AI.max(damage, 0)
        result.type = :damage
        # result.add_status = 0 # TODO
      when :recover
        # TODO
        # item.get_damage(self, battle)
      when :status
        # TODO
      end
      return result
    end
  end
end

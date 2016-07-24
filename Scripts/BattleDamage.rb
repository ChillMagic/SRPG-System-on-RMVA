#=================================================
# SRPG::BattleDamage
#-------------------------------------------------
# Update : 06/21/2016
#=================================================

module SRPG
  module BattleDamage
    # Get Damage
    def self.get_damage_basic(a, b, damagedata)
      basdam = SRPG::AI.make_skill_damage(a, b, DataManager.get_data(:variables), damagedata.formula)
      vardam = damagedata.variance
      return basdam + basdam * AI.rand(-vardam, vardam) / 100
    end
    def self.get_attack_damage(b1, b2)
      if self.attack_use_skill?
        get_skill_damage(b1, b2, 1)
      else
        get_damage_basic(b1, b2, self.attack_damage)
      end
    end
    def self.get_skill_damage(b1, b2, id)
      get_damage_basic(b1, b2, DataManager.get(:skill,id).damage)
    end
    def self.get_item_damage(b1, b2, id)
      get_damage_basic(b1, b2, DataManager.get(:item,id).damage)
    end
    # Damage Evaluate
    def self.damage_evaluate(type, b1, b2, id = nil)
      result = AI::DamageEvaluate.new(0, 0)
      case type
      when :attack
        damage = get_attack_damage(b1, b2)
        result.damage = AI.max(damage, 0)
        # result.add_status = 0 # TODO
      when :skill
        damage = get_skill_damage(b1, b2, id)
        result.damage = damage
      when :item
        damage = get_item_damage(b1, b2, id)
        result.damage = damage
      end
      # case type
      # when :attack
      #   damage = get_attack_damage(b1, b2)
      #   result.damage = AI.max(damage, 0)
      #   # result.add_status = 0 # TODO
      # when :recover
      #   # TODO
      #   # item.get_damage(self, battle)
      # when :status
      #   # TODO
      # end
      return result
    end
  end
end

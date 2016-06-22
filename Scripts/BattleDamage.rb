#=================================================
# SRPG::BattleDamage
#-------------------------------------------------
# Update : 06/21/2016
#=================================================

module SRPG
  module BattleDamage
    # Init
    #  input:
    #    damagelist: Array(Data::Damage)
    #    damagedata: Data::Damage
    def self.set_damagelist(damagelist)
      @@damagelist = damagelist
    end
    def self.get_damagelist
      return @@damagelist
    end
    def self.set_variables(variables)
      @@variables = variables
    end
    # Get Damage
    def self.get_damage_basic(a, b, damagedata)
      basdam = SRPG::AI.make_skill_damage(a, b, @@variables, damagedata.formula)
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
      get_damage_basic(b1, b2, @@damagelist[:skill][id])
    end
    def self.get_item_damage(b1, b2, id)
      get_damage_basic(b1, b2, @@damagelist[:item][id])
    end
    # Damage Evaluate
    def self.damage_evaluate(type, b1, b2, item = nil)
      result = AI::DamageEvaluate.new(0, 0)
      case type
      when :attack
        damage = get_attack_damage(b1, b2)
        result.damage = AI.max(damage, 0)
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

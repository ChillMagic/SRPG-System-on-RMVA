#=================================================
# SRPG::BattleDamage
#-------------------------------------------------
# Update : 06/21/2016
#=================================================

module SRPG
  module BattleDamage
    # Init
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
    def self.get_attack_damage(b1, b2)
      get_damage_formula(b1, b2, @@damagelist[:skill][1].formula)
    end
    def self.get_damage_formula(a, b, formula)
      SRPG::AI.make_skill_damage(a, b, @@variables, formula)
    end
    # Damage Evaluate
    def self.damage_evaluate_basic(type, battlers, item = nil)
      result = AI::DamageEvaluate.new(0, 0)
      case type
      when :attack
        damage = get_attack_damage(*battlers)
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

#=================================================
# SRPG::BaseItem
#-------------------------------------------------
# Update : 02/26/2016
#=================================================

module SRPG
  module AI
    def self.make_skill_damage(user, target, variables, string)
      a = user
      b = target
      v = variables
      begin
        eval(string)
      rescue Exception => res
        putError("Calculator Error in #{self.class}(#{string}) " +
          "for #{a.class}(#{a.id}), #{b.class}(#{b.id}).\n>  " + res.to_s)
      end
    end
  end
  #--------------------------------
  # * Structs
  #--------------------------------
  SelectAction = Struct.new(:type, :id)
  SelectObject = Array


  module BattleDamage
    def self.get_damage(b1, b2, kind)
      # DamageData
    end
    def self.damage_evaluate_basic(type, battlers, item = nil)
      result = AI::DamageEvaluate.new(0, 0)
      case type
      when :attack
        damage = Data::Attack.get_damage(*battlers)
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

module SRPG
  module Data
    Damage = Struct.new(:type, :element_id, :formula, :variance, :critical)
    module BaseItem
      def self.set_variables(variables)
        @@variables = variables
      end
      def self.get_attack_damage(b1, b2)
        get_damage_formula(b1, b2, "a.atk - b.def")
      end
      def self.get_damage_formula(a, b, formula)
        SRPG::AI.make_skill_damage(a, b, @@variables, formula)
      end
    end
    Attack = BaseItem
  end
end













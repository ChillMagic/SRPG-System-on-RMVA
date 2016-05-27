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
  DamageData = Struct.new(:type, :id, :damage)

  module BattleDamage
    def self.get_damage(b1, b2, kind)
      # DamageData
      #b1.atk - b2.def
    end
    def damage_evaluate_basic(type, battler, item = nil)
      result = AI::DamageEvaluate.new(0, 0)
      return putError('The Battler had been dead.') if dead?
      case type
      when :attack
        damage = Data::Attack.get_damage(self,battler)
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

module Test
  Battler = Struct.new(:atk, :def, :mat, :mdf, :agi, :luk, :mhp, :mmp, :hp, :mp, :tp, :level)
  a = Battler.new(5,6,1)
  b = Battler.new(10,0,2)
  v = Array.new(500,0)
  string = "a.atk * 4 - b.def * 2"
  p SRPG::AI.make_skill_damage(a, b, v, string)
  module SRPG
    module Data
      Attack = BaseItem.new
    end
  end
end













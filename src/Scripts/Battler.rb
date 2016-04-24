#=================================================
# SRPG::Battler
#-------------------------------------------------
# Update : 03/17/2016
#=================================================

module SRPG
  #--------------------------------
  # * Module Data::Battler
  #--------------------------------
  class Data::Battler
    attr_reader :id, :type, :datype, :data
    def initialize(id, type, datype, data)
      @id     = id
      @type   = type
      @datype = datype
      @data   = data
    end
    # Basic
    def mhp;    @data.mhp    end
    def mmp;    @data.mmp    end
    def atk;    @data.atk    end
    def def;    @data.def    end
    def mat;    @data.mat    end
    def mdf;    @data.mdf    end
    def agi;    @data.agi    end
    def luk;    @data.luk    end
    # Variable
    def hp;     @data.hp     end
    def hp=(e); @data.hp = e end
    def mp;     @data.mp     end
    def mp=(e); @data.mp = e end
    def tp;     @data.tp     end
    def tp=(e); @data.tp = e end
    # Other
    def level;  @data.level  end
    def move;   @data.move   end
    def view;   @data.view   end
    def note;   @data.note   end
  end
  #--------------------------------
  # * Class Battler
  #--------------------------------
  class Battler < Data::Battler
    def dead?
      self.hp <= 0
    end
    def damage_evaluate(type, battler, item = nil)
      result = AI::DamageEvaluate.new(0, 0)
      return putError("The Battler had been dead.") if dead?
      case type
        when :attack
          result.damage = AI.max(self.atk - battler.def, 0)
        # result.add_status = 0 # TODO
        when :skill
          # TODO
          # item.get_damage(self, battle)
        when :item
          # TODO
          # item.get_damage(self, battle)
        when :status
          # TODO
      end
      return result
    end
    def set_damage(damage)
      self.hp -= AI.min(damage, self.hp)
    end
    # TODO
    def set_add_status(add_status)
      # self.status.add(add_status)
    end
    # def refresh
    #   damage_evaluate(:status)
    # end
    def to_s
      "HP(#{self.hp}), ATK(#{self.atk}), DEF(#{self.def})"
    end
  end
end
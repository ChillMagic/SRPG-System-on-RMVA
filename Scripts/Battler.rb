#=================================================
# SRPG::Battler
#-------------------------------------------------
# Update : 03/17/2016
#=================================================

module SRPG
  #--------------------------------
  # * Class Data::Battler
  #--------------------------------
  module Data
    class Battler < BaseData
      # Basic
      attr_reference :mhp, :mmp, :atk, :def, :mat, :mdf, :agi, :luk
      # Other
      attr_reference :level, :move, :view
      def note
        Data::Note.new(@data.note)
      end
    end
  end
  #--------------------------------
  # * Class Battler
  #--------------------------------
  class Battler < Data::Battler
    # Data
    attr_reader :id, :type, :datype, :data
    # Variable
    attr_referenceref :hp, :mp, :tp
    # Initialize
    def initialize(id, type, datype, data)
      @id     = id
      @type   = type
      @datype = datype
      @data   = data
    end
    def dead?
      self.hp <= 0
    end
    def damage_evaluate(action, object)
      type = action.type
      # TODO
      item = nil
      object.each { |battler| damage_evaluate_basic(type, battler, item) }
    end
    def damage_evaluate_basic(type, battler, baseitem = nil)
      return putError('The Battler had been dead.') if dead?
      return BattleDamage.damage_evaluate(type, self, battler, baseitem)
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

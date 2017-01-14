#=================================================
# SRPG::Battler
#-------------------------------------------------
# Update : 03/17/2016
#=================================================

require_relative 'NewScripts/Data/Battler'

module SRPG
  #--------------------------------
  # * Class Data::Battler
  #--------------------------------
  module Data
    class Battler
      def initialize(data)
        p 1
        @data = data
      end
      def have_nil?
        @data.nil?
      end
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
    attr_reader :id, :type, :datype
    # Initialize
    def initialize(id, type, datype, data)
      p 2
      #p [id, type, datype, data]
      @id     = id
      @type   = type
      @datype = datype
      compatible_initialize(data)
    end

    def compatible_initialize(data)
      @old_data = data
      
      @data = Data::BattlerNew.new
      @data.bparam.mhp = data.mhp
      @data.bparam.mmp = data.mmp
      @data.bparam.pat = data.atk
      @data.bparam.pdf = data.def
      @data.bparam.mat = data.mat
      @data.bparam.mdf = data.mdf
      @data.bparam.agi = data.agi
      @data.bparam.luk = data.luk

      @data.mparam.move = data.move
      @data.mparam.view = data.view

      @hp = data.hp
      @mp = data.mp
      @tp = data.tp
      @level = data.level
    end
    #--------------------------------------
    # + Parameters
    #--------------------------------------
    def hp;    return @hp               end
    def mp;    return @mp               end
    def tp;    return @tp               end
    def level; return @level            end
    def mhp;   return @data.bparam.mhp  end
    def mmp;   return @data.bparam.mmp  end
    def msp;   return @data.bparam.msp  end
    def atk;   return @data.bparam.pat  end
    def def;   return @data.bparam.pdf  end
    def mat;   return @data.bparam.mat  end
    def mdf;   return @data.bparam.mdf  end
    def agi;   return @data.bparam.agi  end
    def luk;   return @data.bparam.luk  end
    def move;  return @data.mparam.move end
    def view;  return @data.mparam.view end
    
    def data;  return @old_data         end


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

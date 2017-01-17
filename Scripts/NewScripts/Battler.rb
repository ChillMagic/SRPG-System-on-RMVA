require_relative 'Data/Battler'

module SRPG
  class Battler
    #--------------------------------------
    # + Attribute
    #--------------------------------------
    attr_reader :id           # Index
    attr_reader :troop_id     # Troop's Index
    attr_reader :data         # Battler Data
    attr_reader :equips       # Eauips

    #--------------------------------------
    # + Initialize
    #--------------------------------------
    def initialize(id, troop_id, battler_data, level, equip)
      Chill.checkType([Integer, Integer, Data::Battler, Data::Equip],
                      [id, troop_id, battler_data, equip])
      @id = id
      @troop_id = troop_id
      @data = battler_data
      @level = level
      @equips = equip # TODO

      @hp = @data.mhp
      @mp = @data.mmp
      @sp = @data.msp
    end

    #--------------------------------------
    # + Parameters
    #--------------------------------------
    def mp;    return @mp        end
    def hp;    return @hp        end
    def sp;    return @sp        end
    def level; return @level     end
    def mhp;   return @data.mhp  end
    def mmp;   return @data.mmp  end
    def msp;   return @data.msp  end
    def pat;   return @data.pat  end
    def pdf;   return @data.pdf  end
    def mat;   return @data.mat  end
    def mdf;   return @data.mdf  end
    def agi;   return @data.agi  end
    def luk;   return @data.luk  end
    def move;  return @data.move end
    def view;  return @data.view end
  end
end

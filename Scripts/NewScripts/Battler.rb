require_relative 'Data/Battler'

puts('loading SRPG::Battler')

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
      Chill.checkType(__LINE__, self.class, __method__,
                      [Integer, Integer, Data::Battler, Data::Equip],
                      [id, troop_id, battler_data, equip])
      @id = id
      @troop_id = troop_id
      @data = battler_data
      @level = level
      @equips = equip # TODO

      @hp = @data.bparam.mhp
      @mp = @data.bparam.mmp
      @sp = @data.bparam.msp
    end

    #--------------------------------------
    # + Parameters
    #--------------------------------------
    def hp;    return @hp               end
    def mp;    return @mp               end
    def sp;    return @sp               end
    def level; return @level            end
    def mhp;   return @data.bparam.mhp  end
    def mmp;   return @data.bparam.mmp  end
    def msp;   return @data.bparam.msp  end
    def pat;   return @data.bparam.pat  end
    def pdf;   return @data.bparam.pdf  end
    def mat;   return @data.bparam.mat  end
    def mdf;   return @data.bparam.mdf  end
    def agi;   return @data.bparam.agi  end
    def luk;   return @data.bparam.luk  end
    def move;  return @data.mparam.move end
    def view;  return @data.mparam.view end
  end
end

require_relative '../System'
require_relative '../Data/Battler'
require_relative '../Data/Equip'

module SRPG
  module Battle
    module Calculator
      def getRealBasicParam(battler_bparam, equip_bparam)
        Chill.checkType(__LINE__, self.class, __method__,
                        [Data::BasicParam, Data::BasicParam],
                        [battler_bparam, equip_bparam])
        bparam = Data::BasicParam.new
        bparam.mhp = battler_bparam.mhp + equip_bparam.mhp
        bparam.mmp = battler_bparam.mmp + equip_bparam.mmp
        bparam.msp = battler_bparam.msp + equip_bparam.msp
        bparam.pat = battler_bparam.pat + equip_bparam.pat
        bparam.pdf = battler_bparam.pdf + equip_bparam.pdf
        bparam.mat = battler_bparam.mat + equip_bparam.mat
        bparam.mdf = battler_bparam.mdf + equip_bparam.mdf
        bparam.agi = battler_bparam.agi + equip_bparam.agi
        bparam.luk = battler_bparam.luk + equip_bparam.luk
        return bparam
      end
      def getRealMapParam(battler_mparam, equip_mparam)
        Chill.checkType(__LINE__, self.class, __method__,
                        [Data::MapParam, Data::MapParam],
                        [battler_mparam, equip_mparam])
        mparam = Data::BasicParam.new
        mparam.move = battler_mparam.move + equip_mparam.move
        mparam.view = battler_mparam.view + equip_mparam.view
        return mparam
      end
    end
  end
end

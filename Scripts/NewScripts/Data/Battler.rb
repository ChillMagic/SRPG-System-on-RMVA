require_relative '../Data/Param'

module SRPG
  module Data
    #----------------------------------------
    # + Struct Data::Battler
    #----------------------------------------
    class Battler
      #--------------------------------------
      # + Include
      #--------------------------------------
      include BasicParamAccessor # Basic Parameter
      include MapParamAccessor   # Map Parameter

      #--------------------------------------
      # + Initialize
      #--------------------------------------
      def initialize
        init_bparam
        init_mparam
      end
    end                       
  end
end

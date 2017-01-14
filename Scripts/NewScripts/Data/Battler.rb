require_relative '../Data/Param'

module SRPG
  module Data
    #--------------------------------------
    # + Struct Data::Battler
    #--------------------------------------
    class BattlerNew
      #--------------------------------------
      # + Attribute
      #--------------------------------------
      attr_accessor :bparam   # Basic Parameter
      attr_accessor :mparam   # Map Parameter

      #--------------------------------------
      # + Initialize
      #--------------------------------------
      def initialize
        @bparam = BasicParam.new
        @mparam = MapParam.new
      end
    end

    #BattlerNew = Battler
  end
end

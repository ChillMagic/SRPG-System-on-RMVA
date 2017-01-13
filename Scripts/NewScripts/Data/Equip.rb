require_relative '../Data/Param'

module SRPG
  module Data
    #--------------------------------------
    # + Struct Data::Equip
    #--------------------------------------
    class Equip
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
  end
end

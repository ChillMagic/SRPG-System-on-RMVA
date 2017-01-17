module SRPG
  module Data
    #--------------------------------------
    # BasicParam : Basic Parameter
    # - mhp : Maximum Hit Point
    # - mmp : Maximum Magic Point
    # - msp : Maximum Skill Point
    # - pat : Physical Attack Power
    # - pdf : Physical Defence Power
    # - mat : Magic Attack Power
    # - mdf : Magic Defence Power
    # - agi : Agility
    # - luk : Luck
    #--------------------------------------
    BasicParam = Struct.new(:mhp, :mmp, :msp, :pat, :pdf, :mat, :mdf, :agi, :luk)

    module BasicParamInit
      attr_accessor :bparam
      def init_bparam
        @bparam = BasicParam.new
      end
    end
    module BasicParamReader
      include BasicParamInit
      def mhp;  return @bparam.mhp  end
      def mmp;  return @bparam.mmp  end
      def msp;  return @bparam.msp  end
      def pat;  return @bparam.pat  end
      def pdf;  return @bparam.pdf  end
      def mat;  return @bparam.mat  end
      def mdf;  return @bparam.mdf  end
      def agi;  return @bparam.agi  end
      def luk;  return @bparam.luk  end
    end
    module BasicParamWriter
      include BasicParamInit
      def mhp=(x)  @bparam.mhp  = x end
      def mmp=(x)  @bparam.mmp  = x end
      def msp=(x)  @bparam.msp  = x end
      def pat=(x)  @bparam.pat  = x end
      def pdf=(x)  @bparam.pdf  = x end
      def mat=(x)  @bparam.mat  = x end
      def mdf=(x)  @bparam.mdf  = x end
      def agi=(x)  @bparam.agi  = x end
      def luk=(x)  @bparam.luk  = x end
    end
    module BasicParamAccessor
      include BasicParamReader
      include BasicParamWriter
    end

    #--------------------------------------
    # MapParam : Map Parameter
    # - move : Move Point
    # - view : View Point
    #--------------------------------------
    MapParam = Struct.new(:move, :view)

    module MapParamInit
      attr_accessor :mparam
      def init_mparam
        @mparam = MapParam.new
      end
    end
    module MapParamReader
      include MapParamInit
      def move; return @mparam.move end
      def view; return @mparam.view end
    end
    module MapParamWriter
      include MapParamInit
      def move=(x) @mparam.move = x end
      def view=(x) @mparam.view = x end
    end
    module MapParamAccessor
      include MapParamReader
      include MapParamWriter
    end
  end
end

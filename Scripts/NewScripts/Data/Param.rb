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

    #--------------------------------------
    # MapParam : Map Parameter
    # - move : Move Point
    # - view : View Point
    #--------------------------------------
    MapParam = Struct.new(:move, :view)
  end
end

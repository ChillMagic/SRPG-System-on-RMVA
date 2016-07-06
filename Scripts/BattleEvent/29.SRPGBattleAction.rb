#==============================================================================
# ■ SRPG::BattleAction
#------------------------------------------------------------------------------
# 　SRPG系统战斗命令的行为解释类。
#==============================================================================

module SRPG
  #--------------------------------
  # * BattleAction
  #--------------------------------
  class BattleAction

    #------------------------------
    # + Basic
    #------------------------------
    # Initialize
    def initialize(imports)
      @imports = imports
    end
    # Set
    def set_action(type, initiator)
      @data = Data::SelectAction.new(type,initiator)
    end
    def set_target(target)
      @data.set_target(target)
    end
    def set_data(data)
      @data.set_data(data)
    end
    # Get
    def get_action
      @data
    end
    def get_type
      @data.type
    end

    #------------------------------
    # + Method
    #------------------------------















  end
end

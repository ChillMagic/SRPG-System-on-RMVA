#==============================================================================
# ■ SRPG::BattleProcess
#------------------------------------------------------------------------------
# 　SRPG系统战斗进程的类。
#==============================================================================

module SRPG
  class BattleProcess
    # Attr
    attr_reader :curr_turn
    # Initialize
    def initialize(imports)
      @imports = imports
    end
    # Basic Import
    def battles; @imports.battles; end
    
    # Status
    #   player operation
    #   wait & show
    
  end
end

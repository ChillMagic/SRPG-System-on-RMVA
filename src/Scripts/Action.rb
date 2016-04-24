#=================================================
# SRPG::Action
#-------------------------------------------------
# Update : 02/23/2015
#=================================================

module SRPG
  class ActionStatus
    attr_reader :moved, :acted
    def initialize(moved = false, acted = false)
      @moved = moved
      @acted = acted
      @record = Array.new
    end
    # Method
    def move
      @moved = true
      @record.push(:move)
    end
    def action
      @acted = true
      move unless Battle.move_after_act?
      @record.push(:action)
    end
    def unmove
      @moved = false
      @record.pop
    end
    
    #def unaction; @acted = false end
    def equip;                   end
    
    def wait
      @record.clear
      setAll(true)
    end
    def reset
      @record.clear
      setAll(false)
    end
    
    def moved?;   @moved end
    def acted?;   @acted end
    def action?;  !over? end
    def over?;    @moved && @acted end
    def can_unmove?; @record.last == :move end
    def can_attack?; !@acted end
      
  private
    def setAll(bool)
      @moved = @acted = bool
    end
  end
  class Setter
    attr_reader :status
    alias old_init initialize
    def initialize(*args)
      old_init(*args)
      @status = ActionStatus.new
    end
  end
end

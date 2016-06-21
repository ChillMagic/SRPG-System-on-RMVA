#==============================================================================
# ■ SRPG::Battle
#------------------------------------------------------------------------------
# 　SRPG系统战斗的驱动类。
#==============================================================================

class SRPG::Battle
  class << self
    def start
#~       p :Start
      @status = true
      @record = self.new
#~       p start?
    end
    def over(result = nil)
      @result = result
      SRPG::Config.battle_result = (result == :win)
      SRPG::Config.battle_over = true
      @record.over
      @status = false
      @record = nil
#~       $game_map.interpreter.setup([], 14)
#~       $game_map.interpreter.run
    end
    def reset
      over if @record
    end
    # Result
    def win?
      @result == :win
    end
    def lose?
      @result == :lose
    end
    def escape?
      @result == :escape
    end
    def interrupt
      @result = :interrupt
    end
    def update
      @record.update
    end
    def start?
      @status
    end
    def over?
      !@status
    end
    # Data
    def data
      @record
    end
    def sprite
      @record.sprites
    end
    # Sprite
    def dispose_sprite
      sprite.dispose
    end
    def view_in?(viewport)
      sprite.viewport == viewport
    end
    def update_sprite(viewport)
      if view_in?(viewport)
        sprite.update
      else
        sprite.refresh(viewport)
      end
    end
  end
end

module SRPG
  #-------------------------
  # * Class BattleState
  #-------------------------
  class BattleState
    #-------------------------
    # + MainState:
    #   :start
    #   :player
    #   :enemy
    #   :friend
    #   :over
    #-------------------------
    # + SubState:
    #   :begin
    #   :update
    #   :end
    #-------------------------
    #   :select_target
    #   :select_command
    #   :show_action
    #-------------------------
    # Const
    PowerActionTurn = [ :player, :enemy, :friend ]
    # Attr
    attr_reader :mainstate, :substate
    # Initialize
    def initialize
      @mainstate = :start
      @substate = :begin
      @handlertable = Hash.new
    end
    def set_handler(flag, state, func)
      @handlertable[flag] ||= Hash.new
      @handlertable[flag][state] = func
    end
    def set_exist_power(powerlist)
      @powerlist = Array.new
      PowerActionTurn.each { |e| @powerlist.push(e) if (powerlist.include?(e)) }
    end
    def change_power
      if (@mainstate == :start || @powerlist.empty?)
        state = PowerActionTurn.first
      else
        i = PowerActionTurn.index(@mainstate)
        state = @powerlist[(i + 1) % @powerlist.size]
      end
      @mainstate = :change
      @nextstate = state
      @substate = :begin
    end
    def over_update
      @substate = :end
    end
    def over_change
      @mainstate = @nextstate
      @substate = :begin
    end
    def get_nextstate
      @nextstate
    end
    def call_function
      get_handler(@mainstate, @substate).call
      if (@substate == :begin)
        @substate = :update
      elsif (@substate == :end)
        get_handler(@mainstate, @substate).call
        if (@mainstate == :change)
          over_change
        else
          change_power
        end
      end
    end

    private
    def get_handler(mstate, sstate)
      @handlertable[mstate] && @handlertable[mstate][sstate] ? @handlertable[mstate][sstate] : -> {
        putError("No Handler for state(#{mstate},#{sstate})")
      }
    end
  end
end

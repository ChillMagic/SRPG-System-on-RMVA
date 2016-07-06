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
    # Import
    def battles
      @imports.battles
    end
    def event
      @imports.event
    end
    def active_post
      @imports.active_post
    end
    def curr_post
      @imports.curr_post
    end
    def get_record(flag)
      @imports.instance_eval{get_record(flag)}
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
    def clear_action
      @data = nil
    end
    # Get
    def get_action
      @data
    end
    def get_type
      @data ? @data.type : nil
    end

    #------------------------------
    # + Method
    #------------------------------
    def show_range
      # show_range
      case get_type
      when :move
        @imports.show_range(active_post,:move)
      when :attack
        @imports.show_range(active_post,:attack_opt)
        @imports.adjust_direction
      when :skill
        @imports.show_ranges([active_post,:skill_opt],[curr_post,:skill_elt])
        @imports.adjust_direction
      end
    end
    def hide_range
      case get_type
      when :move
        @imports.hide_range(true)
        @imports.goto(Battle::ShowMoveFirst ? :select : :select_action)
      when :attack
        @imports.active_event.set_direction(get_record(:attk_direction))
        if (get_record(:move_attack))
          @imports.event_move_recover
          @imports.hide_range
          @imports.goto(:select_move)
        else
          @imports.hide_range(true)
          @imports.goto(:select_action)
        end
      when :skill
        @imports.hide_range(true)
        @imports.goto(:select_action)
      end
    end
    def update_range
      case get_type
      when :skill
        event.refresh_range_top(curr_post, :skill_elt)
      end
    end
    def do_check
      set_target(curr_post)
      case get_type
      when :move
        result = @imports.event_move_start(*curr_post.position)
        if (result)
          @imports.hide_range
          @imports.goto(:doing)
        end
      when :attack
        result = battles.check_action(get_action)
        if (result)
          @imports.damage_status_show
          @imports.goto(:select_confirm)
        end
      when :skill
        result = battles.check_action(get_action)
        if (result)
          @imports.hide_range
          @imports.damage_status_show
          @imports.decord_cursor
          @imports.goto(:select_confirm)
        end
      end
    end
    def do_start
      case get_type
      when :attack
        event.attack(active_post,curr_post)
      when :skill
        event.attack(active_post,curr_post)
      end
    end
    def do_confirm
      case get_type
      when :move
      when :attack, :skill
        @imports.hide_range
        do_start
        @imports.goto(:doing)
      end
    end
    def do_over
      case get_type
      when :move
        @imports.goto(get_record(:move_attack) ? :select_attack : :select_action)
      when :attack
        @imports.damage_status_hide
        @imports.goto(:select_action)
      when :skill
        @imports.damage_status_hide
        @imports.goto(:select_action)
      end
      clear_action
    end
  end
end

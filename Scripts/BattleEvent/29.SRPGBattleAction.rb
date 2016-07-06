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
    include Config
    #------------------------------
    # + Basic
    #------------------------------
    # Initialize
    def initialize(imports)
      @imports = imports
    end
    # Import
    def battles;          @imports.battles;     end
    def event;            @imports.event;       end
    def active_post;      @imports.active_post; end
    def curr_post;        @imports.curr_post;   end
    def get_record(flag); @imports.instance_eval{get_record(flag)}; end
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
      when :skill
        @imports.show_ranges([active_post,:skill_opt],[curr_post,:skill_elt])
      end
    end
    def hide_range
      case get_type
      when :move
        @imports.hide_range(true)
        @imports.goto(ShowMoveFirst ? :select : :select_action)
      when :attack
        if (get_record(:move_attack))
          @imports.event_move_recover
          @imports.hide_range
          @imports.goto(:select_move)
        else
          @imports.hide_range(true)
          @imports.recover_direction
          @imports.goto(:select_action)
        end
      when :skill, :item
        @imports.hide_range(true)
        @imports.recover_direction
        @imports.goto(:select_action)
      end
    end
    def update_range
      case get_type
      when :move
      when :attack
        @imports.adjust_direction
      when :skill
        @imports.adjust_direction
        event.refresh_range_top(curr_post, :skill_elt)
      when :item
        @imports.adjust_direction
      end
    end
    def do_check
      set_target(curr_post)
      result = false
      case get_type
      when :move
        result = @imports.event_move_start(*curr_post.position)
        if (result)
          @imports.hide_range
          @imports.goto(:doing)
        end
      when :attack, :skill, :item
        result = battles.check_action(get_action)
        if (result)
          @imports.hide_range
          @imports.damage_status_show
          @imports.decord_cursor
          @imports.goto(:select_confirm)
        end
      end
      return result
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
      when :attack, :skill, :item
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

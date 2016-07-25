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
    include ActionBasic
    #------------------------------
    # + Basic
    #------------------------------
    # Initialize
    def initialize(imports)
      @imports = imports
    end
    # Import
    def battles;              @imports.battles;     end
    def event;                @imports.event;       end
    def active_post;          @imports.active_post; end
    def curr_post;            @imports.curr_post;   end
    def get_record(*args);    @imports.instance_eval{get_record(*args)};    end
    def set_record(*args);    @imports.instance_eval{set_record(*args)};    end
    def change_record(*args); @imports.instance_eval{change_record(*args)}; end
    #------------------------------
    # + Method
    #------------------------------
    def show_range
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
          move_recover
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
      p get_action
      return battles.check_action(get_action)
    end
    def do_start
      @imports.hide_range
      case get_type
      when :move
      when :attack, :skill, :item
        @imports.damage_status_show
        @imports.decord_cursor
      end
      do_things
    end
    def do_cancel
      @imports.damage_status_hide
      # hide_range
    end
    def do_things
      case get_type
      when :move
        move_start
      when :attack
        event.attack(active_post,curr_post)
      when :skill
        event.skill(get_data,active_post,curr_post)
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
    # From ActivePost to a setter.
    def move_start
      event.move(active_post, *get_data[1])
      set_record(:move_position,  active_post.position)
      set_record(:move_direction, @imports.active_event.direction)
      change_record(:move_attack, get_data[0])
      @imports.record_direction if (get_data[0])
    end
    def move_recover
      active_post.status.unmove
      x, y = get_record(:move_position)
      if (active_post.position != [x, y])
        @imports.active_event.set_direction(get_record(:move_direction))
        active_post.moveTo(x,y)
        @imports.active_event.moveto(x,y)
      end
    end
  end
end

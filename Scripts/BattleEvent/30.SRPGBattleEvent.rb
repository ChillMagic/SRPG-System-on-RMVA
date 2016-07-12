#==============================================================================
# ■ SRPG::BattleEvent
#------------------------------------------------------------------------------
#   SRPG系统战斗的驱动支持类。
#==============================================================================

module SRPG
  class BattleEvent
    # Include
    include SRPG
    include Data
    include EventBasic
    # Const
    EventKey   = {
        move:   RankData.new(:move_start,   :moving,  :move_over),
        show:   RankData.new(:show_start,   :showing, :blank),
        attack: RankData.new(:attack_start, :over,    :attack_over),
        skill:  RankData.new(:skill_start,  :over,    :skill_over),
        item:   RankData.new(:item_start,   :over,    :item_over),
        wait:   RankData.new(:wait_start,   :waiting, :blank)
    }
    # Initialize
    def initialize(imports)
      super(EventKey)
      @imports = imports
    end
    # Basic Import
    def battles; @imports.battles; end
    def sprites; @imports.sprites; end
    def windows; @imports.windows; end
    #-------------------------------
    # * Event Import
    #-------------------------------
    def move(setter, x, y, view = nil)
      move_start(setter, x, y, view)
    end
    def attack(setter, target)
      attack_start(setter, target)
    end
    def skill(id, setter, target)
      skill_start(id, setter, target)
    end
    def show_animation(setter, animation_id)
      show_start(setter, animation_id)
    end
    #---------------------
    # Wait
    def wait(duration)
      wait_start(duration)
    end
    #---------------------
    # Cursor
    def set_cursor(x, y)
      sprites.set_cursor(x,y)
      @imports.player.moveto(x,y)
    end
    def move_cursor(setter)
      # TODO
      sprites.move_cursor(*setter.position)
      @imports.player.moveto(*setter.position)
      @imports.refresh_mapstatus2(setter)
    end
    #---------------------
    # Show Range
    def show_range(setter, type)
      show_range_basic(setter, type)
    end
    def show_ranges(*datas)
      datas.each { |dat| show_range_basic(*dat,false) }
      sprites.ranges.show
    end
    def hide_range
      sprites.hide_range
    end
    def refresh_range_top(setter, type)
      sprites.ranges.pop
      show_range_basic(setter, type, false)
    end

    private
    #---------------------
    # Event
    def event(setter)
      @imports.get_event(setter)
    end
    #---------------------
    # Range
    def show_range_basic(setter, type, refresh = true)
      ranges = battles.get_range_color_datas(setter, type)
      sprites.push_range(ranges,refresh)
      return ranges
    end
    #---------------------
    # Move
    def move_start(setter, x, y, view)
      return false if ([x,y] == setter.position)
      event = event(setter)
      move_way = battles.get_route(setter,view).get_path(x,y)
      unless move_way
        putError("Can't find path to (#{x}, #{y}) for #{setter}.")
        return false
      end
      move_way = move_way[0,setter.data.move] if view
      x, y = SRPG::Route.get_route_points(*setter.position,move_way).last
      return false if (!battles.get_setter(x,y).blank?)
      set_cursor(x, y) if (setter.type != :actor)###
      setflag(:move)
      set_record(:move_way, move_way)
      set_record(:move_point, [x,y])
      set_record(:move_setter, setter)
      set_record(:move_event_speed, event.move_speed)
      event.move_speed = battles.get_event_movespeed(setter)
      return true
    end
    def moving
      event = event(get_record(:move_setter))
      return if (event.moving?)
      if (get_record(:move_way).empty?)
        over
      else
        event.move_with(get_record(:move_way).shift)
      end
    end
    def move_over
      setter = get_record(:move_setter)
      setter.status.move
      if (get_record(:move_way,false))
        setter.moveTo(*get_record(:move_point))
        event(setter).move_speed = get_record(:move_event_speed)
      end
    end
    #--------
    # Attack
    def attack_start(setter, target)
      return false unless battles.is_battler?(target)
      setflag(:attack)
      set_record(:attk_setter,setter)
      set_record(:attk_target,target)
      show_animation(*battles.get_attack_animation(setter,target))
      set_direction(setter, target)
      if (battles.attack(setter,target))
        set_dead_setter(target)
      end
      move_cursor(target)
      return true
    end
    def attack_over
      setter = get_record(:attk_setter)
      target = get_record(:attk_target)
      return if setter.nil?
      setter.status.action
      # TODO : Need to imprave.
      move_cursor(setter)
      p setter.data
      @imports.windows[:mapstatus].refresh(target.data)
    end
    def set_direction(cur_pos, tar_pos)
      ce = event(cur_pos)
      ce.set_direction(battles.attack_direction(cur_pos, tar_pos, ce.direction))
    end
    def skill_start(id, setter, target)
      setflag(:skill)
      set_record(:attk_setter,setter)
      func = lambda { |target| show_animation(*battles.get_attack_animation(setter,target)) } # TODO
      set_direction(setter, target)
      battles.use_skill_real(id, setter,target,func).each do |dead_setter|
        set_dead_setter(dead_setter)
      end
      move_cursor(target)
      return true
    end
    def skill_over
      setter = get_record(:attk_setter)
      setter.status.action
    end
    def set_dead_setter(target)
      # TODO : To show an animation for dead.
      # event(target).erase
      battles.push_dead_event(event(target))
      event(target).transparent = true
      target.clear
    end
    #--------
    # Show Animation
    def show_start(setter, animation_id)
      setflag(:show)
      event(setter).animation_id = animation_id
      set_record(:show_event,event(setter))
      set_afterdo(:wait,10)
      return true
    end
    def showing
      over if (get_record(:show_event).nil? || get_record(:show_event).animation_id.zero?)
    end
    #---------------------
    # Wait
    def wait_start(duration)
      setflag(:wait)
      set_record(:wait,duration)
    end
    def waiting
      if (get_record(:wait) <= 0)
        over
      else
        change_record(:wait,get_record(:wait)-1)
      end
    end
    #-------------------------
  end
end

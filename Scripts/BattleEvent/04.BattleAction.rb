module SRPG
  #-------------------------
  # * Class BattleAction
  #-------------------------
  class BattleAction
    include ActionBasic
    def initialize(interface)
      @doneaction = false
      init_interface(interface)
      init_handler
    end
    def clear_action
      super
      @doneaction = false
      init_handler
    end
    def do_check
      puts("#{__method__}, #{self.get_type}")
      case self.get_type
      when :move
        range = @bdata.get_range(:move,initiator)
        x, y = *target.position
        return true if target.position == initiator.position
        return range.include?(x,y) && target.blank?
      when :attack
        orange = @bdata.get_range(:attack_opt,initiator)
        erange = @bdata.get_range(:attack_elt,initiator)
        x, y = *target.position
        return orange.include?(x,y) && @bdata.is_enemy?(initiator,target)
      when :skill
        orange = @bdata.get_range(:skill_opt,initiator,self.get_data)
        erange = @bdata.get_range(:skill_elt,initiator,self.get_data)
        x, y = *target.position
        return orange.include?(x,y) && @map.include_type?(erange, [:enemy])
      when :item
        orange = @bdata.get_range(:item_opt,initiator,self.get_data)
        erange = @bdata.get_range(:item_elt,initiator,self.get_data)
        x, y = *target.position
        return orange.include?(x,y) && @map.include_type?(erange, [:enemy])
      when :equip
        return true
      when :wait
        return true
      end
    end
    def do_start
      case self.get_type
      when :move
        route = @bdata.get_route(initiator)
        moveway = route.get_path(*target.position)
        event = @bdata.get_event(initiator)
        rec_movespeed = event.move_speed
        event.move_speed = @bdata.get_event_movespeed(initiator)
        position = initiator.position
        direction = event.direction
        @doingfunc  = -> { doing_move(moveway) }
        @donefunc   = -> { done_move(rec_movespeed) }
        @cancelfunc = -> { cancel_move(position, direction) }
      when :attack
        @bdata.do_attack(initiator, target)
        @windows.show_damage_statusX(initiator.data, target.data)
        event = @bdata.get_event(initiator)
        event.animation_id = 1
        @sprites.hide_range
        @doingfunc  = -> { doing_attack }
        @donefunc   = -> { done_attack }
      when :skill
      when :item
      when :equip
      when :wait
      end
    end
    #-------------------------
    # + Doing
    #-------------------------
    def doing
      res = @doingfunc.call
      done if (res)
      return res
    end
    def doing_move(moveway)
      event = @bdata.get_event(initiator)
      return false if (event.moving?)
      return true if (moveway.empty?)
      event.move_with(moveway.shift)
      return false
    end
    def doing_attack
      event = @bdata.get_event(initiator)
      return false if (event.animation_id != 0)
      initiator.status.action
      return true
    end
    #-------------------------
    # + Done
    #-------------------------
    def done
      @donefunc.call
      @doneaction = true
    end
    def done?
      @doneaction
    end
    def done_move(rec_movespeed)
      initiator.moveTo(*target.position)
      initiator.status.move
      event = @bdata.get_event(initiator)
      event.move_speed = rec_movespeed
    end
    def done_attack
      @windows.hide_damage_statusX
    end
    #-------------------------
    # + Cancel
    #-------------------------
    def do_cancel
      if @cancelfunc && @cancelfunc.call
        @doneaction = false
        return true
      end
      return false
    end
    def cancel_move(position, direction)
      return false unless initiator.status.can_unmove?
      initiator.moveTo(*position)
      initiator.status.unmove
      event = @bdata.get_event(initiator)
      event.moveto(*position)
      event.set_direction(direction)
      @sprites.show_range(*@bdata.get_show_range(:move,initiator))
      @interface.set_playerstate(:select,:action,self.get_type)
      return true
    end
    #-------------------------
    # + Private
    #-------------------------
    private
    def init_interface(interface)
      @interface = interface
      @map       = interface.map
      @bdata     = interface.data
      @sprites   = interface.sprites
      @windows   = interface.windows
    end
    def init_handler
      @doingfunc  = ->{ true }
      @donefunc   = ->{}
      @cancelfunc = ->{}
    end
    def target
      self.get_target
    end
    def initiator
      self.get_initiator
    end
  end
end

module SRPG
  #-------------------------
  # * Class BattleData
  #-------------------------
  class BattleData
    # Include
    include SRPG
    include Record
    include Config
    # Const
    EnemyTypeData = {
        actor:  [:enemy],
        friend: [:enemy],
        enemy:  [:actor, :friend],
    }
    PartyTypeData = {
        actor:  [:actor, :friend],
        friend: [:actor, :friend],
        enemy:  [:enemy],
    }
    RangeColor = {
        move: Data::Color::Blue,
        atk_opt: Data::Color::Orange,
        atk_elt: Data::Color::Red,
        eff_opt: Data::Color::Celeste,
        eff_elt: Data::Color::Green,
    }
    #-------------------------
    # * Initialze
    #-------------------------
    def initialize(map)
      @map = map
    end
    #-------------------------
    # * Basic Data
    #-------------------------
    def curr_position
      [$game_player.x, $game_player.y]
    end
    def get_event_movespeed(setter)
      return EventMoveSpeed
    end
    def get_event(setter)
      $game_map.events[setter.id]
    end
    #-------------------------
    # * Battle Inquiry
    #-------------------------
    def is_enemy?(s1, s2)
      EnemyTypeData[s1.type] && EnemyTypeData[s1.type].include?(s2.type)
    end
    def is_party?(s1, s2)
      PartyTypeData[s1.type] && PartyTypeData[s1.type].include?(s2.type)
    end
    def turn_over?(type)
      @map.datalist[type].all? { |s| s.status.over? }
    end
    def turn_over(type)
      @map.datalist[type].each { |s| s.status.reset }
    end
    #-------------------------
    # * Battle Do
    #-------------------------
    def do_attack(sa, sb)
      call_damage(:attack, sa.data, sb.data)
    end
    def call_damage(type, a, b, id = 0)
      return putError("Error in Nil Batter.") if (a.nil? || b.nil?)
      baseitem = (type == :attack) ? a.get_attack_data : DataManager.get(type,id)
      result = a.damage_evaluate_basic(type, b, baseitem)
      return putError("Error in Battle Result.") if (result.nil?)
      b.set_damage(result.damage)
      return b.dead?
    end
    #-------------------------
    # * Show
    #-------------------------
    # Action Direction
    #   (dx, dy)
    #   (<, <), (=, <), (>, <)
    #   (<, =), (=, =), (>, =)
    #   (<, >), (=, >), (>, >)
    def action_direction(cur_pos, tar_pos, cur_dir)
      c, t = cur_pos.position, tar_pos.position
      dx, dy = (t[0] - c[0]), (t[1] - c[1])
      dir = Data::Move::DirR2S[cur_dir]
      if (dx == 0 && dy != 0)
        dir = (dy > 0) ? :DOWN : :UP
      elsif (dy == 0 && dx != 0)
        dir = (dx > 0) ? :RIGHT : :LEFT
      elsif (dy < 0 && dir == :DOWN)
        dir = :UP
      elsif (dy > 0 && dir == :UP)
        dir = :DOWN
      elsif (dx < 0 && dir == :RIGHT)
        dir = :LEFT
      elsif (dx > 0 && dir == :LEFT)
        dir = :RIGHT
      end
      return Data::Move::DirS2R[dir]
    end
    #-------------------------
    # * Command Inquiry
    #-------------------------
    def is_controled?(setter)
      case setter.type
      when :actor;  true
      when :enemy;  Battle.control_enemy?
      when :friend; Battle.control_friend?
      else;         false
      end
    end
    def can_control?(setter)
      return is_controled?(setter) && setter.status.action?
    end
    def normal_attack_signle?
      true
    end
    def item_use_range?
      false
    end
    #-------------------------
    # * Get Range
    #-------------------------
    def get_range(type, setter, id = nil)
      case type
      when :move
        range = get_move_range(setter)
      when :attack_opt
        range = setter.data.attack_optional_range(setter.position)
      when :attack_elt
        range = setter.data.attack_elected_range(curr_position)
      when :skill_opt
        range = DataManager.get(:skill,id).optional_range(setter.position)
      when :skill_elt
        range = DataManager.get(:skill,id).elected_range(curr_position)
      when :item_opt
        range = DataManager.get(:item,id).optional_range(setter.position)
      when :item_elt
        range = DataManager.get(:item,id).elected_range(curr_position)
      else
        return putError("Unfind type(#{type}) in function(#{__method__}).")
      end
      return range ? range : SRPG::Range.new
    end
    def get_show_range(type, *args)
      setter = args[1]
      case type
      when :move
        return [->{ [get_range(:move,*args), RangeColor[:move]] }]
      when :attack
        orange = get_range(:attack_opt,*args)
        return [->{ [orange, RangeColor[:atk_opt]] },
                normal_attack_signle? ? nil : ->{ [get_range(:attack_elt,*args), RangeColor[:atk_elt]] } ]
      when :skill
        orange = get_range(:skill_opt,*args)
        return [->{ [orange, RangeColor[:atk_opt]] },
                orange.empty? ? nil : ->{ [get_range(:skill_elt,*args), RangeColor[:atk_elt]] } ]
      when :item
        # This is effective when 'item_use_range?' is 'true'.
        orange = get_range(:item_opt,*args)
        return [->{ [orange, RangeColor[:atk_opt]] },
                orange.empty? ? nil : ->{ [get_range(:item_elt,*args), RangeColor[:atk_elt]] } ]
      end
    end
    def get_move_range(setter, move = nil)
      route = get_route(setter, move)
      return route.get_points
    end
    #-------------------------
    # * Get Route
    #-------------------------
    MoveRouteRecord = Struct.new(:chrecord, :route)
    def get_route(setter, move = nil)
      if (move.nil?)
        # Record Check
        first_set_record(__method__,Hash.new)
        record = (get_record(__method__)[setter] ||= MoveRouteRecord.new)
        return record.route if (@map.chrecord == record.chrecord)
        # Get Route
        route = get_route_basic(setter, setter.data.move)
        # Set Record
        record.chrecord, record.route = @map.chrecord, route
      else
        # Get Route
        route = get_route_basic(setter, move)
      end
      # Return
      return route
    end
    def get_route_basic(setter, move)
      if (move.nil?)
        putError("None move for #{setter.type}(#{setter.data.id}).")
        move = 0
      end
      passmap = @map.get_passmap(EnemyTypeData[setter.type])
      route = Route.new(passmap, *setter.position)
      route.search(move)
      return route
    end
  end
end

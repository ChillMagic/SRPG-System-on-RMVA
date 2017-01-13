#==============================================================================
# ■ SRPG::BattleData
#------------------------------------------------------------------------------
# 　SRPG系统战斗的数据支持类。本部分负责处理范围的计算问题。
#==============================================================================

module SRPG
  class BattleData
    #-------------------------
    # * Get Range
    #-------------------------
    def get_range(type, setter, move = nil)
      case type
      when :m   # Move
        route = get_route(setter,move)
        return route.get_points
      when :ao  # Attack Optional Basic
        return setter.data.attack_optional_range
      when :aom # Attack Optional Moved
        return get_range(:ao,setter).move(*setter.position)
      when :aoa # Attack Optional All
        mrange = get_range(:m,setter,move)
        arange = get_range(:ao,setter)
        return AI.get_attack_range(mrange,arange)
      when :aos # Attack Optional Subtract
        mrange = get_range(:m,setter,move)
        arange = get_range(:aoa,setter)
        return arange.diff(mrange)
      when :ae  # Attack Elected
        return setter.data.attack_elected_range.move(*setter.position)
      when :so  # Skill Optional Basic
        id = @actions.get_data
        return DataManager.get(:skill,id).useable_range.get_range(:optional)
      when :som # Skill Optional Moved
        return get_range(:so,setter).move(*setter.position)
      when :soa # Skill Optional All
        mrange = get_range(:m,setter,move)
        srange = get_range(:so,setter)
        return AI.get_attack_range(mrange,srange)
      when :se  # Skill Elected
        id = @actions.get_data
        return DataManager.get(:skill,id).useable_range.get_range(:elected,setter.position)
      end
    end
    # def check_range_of(range, *types)
    #   range.any? { |x,y| types.include?(@map[x,y].type) if (@map[x,y]) }
    # end
    # def get_object_of_skill(range, type)
    #   range.select { |x,y| @map[x,y] && @map[x,y].type == type }.collect { |x,y| @map[x,y] }
    # end
    #-------------------------
    # * Get PassMap
    #-------------------------
    def get_pass_map(type)
      @map.get_passmap(EnemyTypeData[type])
    end
    #-------------------------
    # * Get Route
    #-------------------------
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
      passmap = get_pass_map(setter.type)
      route = Route.new(passmap, *setter.position)
      route.search(move)
      return route
    end
    def get_attack_list(setter, move = nil)
      r = get_range(:aoa,setter,move)
      r.select { |x,y| is_enemy?(setter,get_setter(x,y)) }.collect { |x,y| get_setter(x,y) }
    end
    def get_attack_move_point(setter, x, y, move = nil)
      route   = get_route(setter,move)
      mrange  = get_range(:m,setter,move).diff(@map.get_range_of_setter).union([setter.position])
      abrange = get_range(:ao,setter,move)
      return AI.get_attack_point(route, mrange, abrange, x, y)
    end
  end
end

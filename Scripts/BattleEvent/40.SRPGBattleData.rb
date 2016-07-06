#==============================================================================
# ■ SRPG::BattleData
#------------------------------------------------------------------------------
# 　SRPG系统战斗的数据支持类。
#==============================================================================

module SRPG
  class BattleData
    # Attr
    attr_reader :map, :datalist
    # Include
    include SRPG
    include Config
    include Record
    include Data::Move
    # Const
    MoveType = { pass: 1, unpass: 0 }
    EnemyTypeData = {
        actor:  [:enemy],
        enemy:  [:actor, :friend],
        friend: [:enemy]
    }
    RangeColor      = Struct.new(:range, :color)
    MoveRouteRecord = Struct.new(:chrecord, :route)
    # Initialize
    def initialize
      @map, @datalist = Data::MapData.get_settermap
      @passmap = Data::MapData.get_passmap
      start
    end
    #-------------------------
    # * Start
    #-------------------------
    def start
      set_data
    end
    def set_data
      set_actionlist
#~       puts @datalist
#~       puts @actionlist
    end
    # Set SetterMap
    def set_actionlist
      record = Array.new
      @datalist.each_with(:actor,:enemy,:friend) do |setter|
        record.push([get_action_value(setter),setter])
      end
      record.sort! { |x, y| y[0] <=> x[0] }
      @actionlist = SetterList.new(record.collect{|rec|rec.last})
    end
    def get_action_value(setter)
      # ! Action List Sort !
      return [setter.data.agi, setter.data.level]
    end
    
    #-------------------------
    # * Command
    #-------------------------
    def reset_status
      @map.each { |e| e.status.reset }
    end
    
    #-------------------------
    # * Command Inquiry
    #-------------------------
    def is_controled?(setter)
      case setter.type
      when :actor;  true
      when :enemy;  Battle.control_enemy?
      when :friend; Battle.control_friend?
      end
    end
    def can_control?(setter)
      return false unless is_battler?(setter)
      cond1 = setter.status.action?
      cond2 = is_controled?(setter)
      return cond1 && cond2
    end
    def show_action_menu?(setter)
      status = setter.status
      ShowWaitCommand || !status.over? || status.can_unmove?
    end
    #-------------------------
    # * Turn Inquiry
    #-------------------------
    def battle_first_action
      return :player
    end
    def turn_over?(type)
      @datalist[type].all? { |s| s.status.over? }
    end
    def turn_over(type)
      @datalist[type].each { |s| s.status.reset }
    end
    
    # TODO
    def have_friend?
      !@datalist[:friend].empty?
    end
    #-------------------------
    # * BattleStatus Inquiry
    #-------------------------
    def battle_over?
      actor = @datalist[:actor]
      enemy = @datalist[:enemy]
      actor.clear
      enemy.clear
      if (actor.empty?)
        set_over_flag(:lose)
      elsif (enemy.empty?)
        # TODO
        set_over_flag(:win)
      end
      return !over_flag.nil?
    end
    def set_over_flag(inc)
      @overflag = inc
    end
    private :set_over_flag
    def over_flag
      @overflag
    end
    def push_dead_event(e)
      @dead_event ||= Array.new
      @dead_event.push(e)
      #~ puts @dead_event
    end
    #-------------------------
    # * Battler Inquiry
    #-------------------------
    def is_battler?(setter)
      return EnemyTypeData.has_key?(setter.type)
    end
    def is_enemy_type?(typea, typeb)
      EnemyTypeData[typea].include?(typeb)
    end
    def is_enemy?(setter, target)
      return false if target.nil?
      return is_enemy_type?(setter.type,target.type)
    end
    #-------------------------
    #  * Move/Attack Inquiry
    #-------------------------
    def can_move?(setter, x, y)
      range  = get_route(setter).get_points
      moveto = get_setter(x,y)
      return (range.include?(x,y) && (moveto.blank? || (setter == moveto)))
    end
    def can_damage?(setter, target)
      return Battle.can_attack_self? ? is_battler?(target) : is_enemy?(setter,target)
    end
    def can_attack?(setter, target, allrange)
      if (allrange)
        return false unless can_damage?(setter, target)
        range = get_range(:aoa, setter)
        return range.include?(*target.position)
      else
        return putError("The function '#{__method__}' will be delete.")
      end
    end
    def can_move_attack?(setter, x, y)
      return false unless ShowMoveAttack
      return false unless setter.status.can_attack?
      return false unless can_attack?(setter,get_setter(x,y),true)
      return false unless get_range(:aos,setter).include?(x,y)
      return get_attack_move_point(setter,x,y)
    end
    #-------------------------
    # * Condition Inquiry
    #-------------------------
    def get_intype(setter, type)
      # TODO
      st = setter.status
      cond = ShowMoveAttack && (type == :move) && (st.can_attack? || st.over?)
      return cond ? :move_attack : type
    end
    #-------------------------
    # * Get Basic
    #-------------------------
    def get_setter(x, y)
      @map[x,y]
    end
    #-------------------------
    # * Get List
    #-------------------------
    def get_attack_list(setter, move = nil)
      data = Array.new
      get_range(:aoa,setter,move).each do |x,y|
        target = get_setter(x,y)
        data.push(target) if is_enemy?(setter,target)
      end
      return data
    end
    #-------------------------
    # * Get BaseItem Data
    #-------------------------
    # TODO
    # description :
    # input : skill_id
    # ouput : Data::Skill
    def get_skill(id)

    end
    #-------------------------
    # * Get ShowData
    #-------------------------
    def get_attack_animation(setter, target)
      # TODO
      return [ target, setter.data.normal_attack_animation_id ]
    end
    def get_event_movespeed(setter)
      return EventMoveSpeed
    end
    def get_range_color(setter, basictype)
      result = RangeColor.new
      result.range = get_range(basictype,setter)
      colortype  = :move
      settertype = setter.type
      case basictype
      when :m
        colortype  = :move
        settertype = :actor unless (ShowEmyDiffer)
      when :aoa, :aos, :aom, :soa, :som
        colortype  = :attack_opt
        settertype = :actor unless (ShowEmyDiffer)
      when :ae
        colortype  = :attack_elt
      when :se
        colortype  = :attack_elt
        settertype = :actor
      end
      result.color = Data::Color.get_range_color(colortype,settertype)
      return result
    end
    def get_range_color_datas(setter, type)
      datas = Array.new
      case type
        when :move
          datas.push(get_range_color(setter,:m))
        when :move_attack
          datas.push(get_range_color(setter,:m))
          datas.push(get_range_color(setter,:aos))
        when :attack_opt
          datas.push(get_range_color(setter,:aom))
        when :attack_elt
          datas.push(get_range_color(setter,:ae))
        when :skill_opt
          datas.push(get_range_color(setter,:som))
        when :skill_elt
          datas.push(get_range_color(setter,:se))
        when :skill_optt
          datas.push(get_range_color(setter,:som))
          datas.push(get_range_color(setter,:se))
      end
      return datas
    end
  end
end

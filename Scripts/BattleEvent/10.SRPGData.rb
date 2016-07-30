#==============================================================================
# ■ SRPG::Data
#------------------------------------------------------------------------------
# 　SRPG系统战斗的基本模块。负责设定和转化数据。用于联系Kernel与RGSS。
#==============================================================================

module SRPG::Data
  include SRPG
  include Config

  module Color
    Range = {
        move:       { actor:  :blue,   enemy:  :orange, friend: :celeste },
        attack_opt: { actor:  :orange, enemy:  :red,    friend: :orange },
        attack_elt: { actor:  :red,    enemy:  :red,    friend: :red }
    }
    def self.get_range_color(type, settype)
      Spriteset_Range.get_constexpr(Range[type][settype])
    end
  end

  class BaseItem
    def damage
      dam = Damage.new(@data.damage)
      dam.type = useable_damage_type_data
      dam
    end
    private
    def useable_range_type_data
      case @data.scope
      when 0  # 0:  无      -> 无
        [:none,  :none]
      when 1  # 1:  单个敌人 -> 个体敌人
        [:indiv, :enemy]
      when 2  # 2:  全体敌人 -> 范围敌人
        [:range, :enemy]
      when 7  # 7:  单个队友 -> 个体队友
        [:indiv, :party]
      when 8  # 8:  全体队友 -> 范围队友
        [:range, :party]
      when 11 # 11: 使用者   -> 使用者
        [:self,  :party]
      else
        []
      end
    end
    def optional_range_data
      self.note.get_range(:Opt)
    end
    def elected_range_data
      self.note.get_range(:Elt)
    end
    def useable_damage_type_data
      DamageType[@data.damage.type]
    end
  end
  class Attack
    def initialize(data)
      @opt_range, @ele_range = data[:useablerange][:optional], data[:useablerange][:elected]
      @damage = data[:damage]
    end
    def damage
      @damage
    end
    private
    def useable_range_type_data
      [:indiv, :enemy]
    end
    def optional_range_data
      @opt_range
    end
    def elected_range_data
      @ele_range
    end
    def useable_damage_type_data
      :hp_damage
    end
  end
  class Weapon
    include UseableRangeModule
    private
    def useable_range_type_data
      [:range, :enemy]
    end
    def optional_range_data
      self.note.get_range(:Opt)
    end
    def elected_range_data
      self.note.get_range(:Elt)
    end
    def useable_damage_type_data
      :hp_damage
    end
  end

  class Battler
    include SRPG
    include Config
    #------------------
    # + UseableRange
    #------------------
    def get_attack_data
      @attack_data ||= Data::Attack.new(attack_data)
    end
    def get_skill_data(id = nil)
      id.nil? ? @skills.collect { |id| DataManager.get(:skill,id) } : DataManager.get(:skill, id)#@skills[id])
    end
    def attack_optional_range
      get_attack_data.useable_range.get_range(:optional)
    end
    def attack_elected_range
      get_attack_data.useable_range.get_range(:elected)
    end
    #------------------
    # + Animation
    #------------------
    def normal_attack_animation_id
      if (weapon)
        weapon.animation_id
      else
        self.note.animation ? self.note.animation : 1
      end
    end
    #------------------
    # + Equip
    #------------------
    def weapon
      weapons.first.nil? ? nil : Data::Weapon.new(weapons.first)
    end
    # Data
    def armors
      @data.armors
    end
    def equips
      @data.equips
    end
    def weapons
      if (@datype == :actor)
        @data.weapons
      else
        []
      end
    end
    def refresh
    end
    private
    AttackLoadDataType = [
        :default, # 默认（自设定）
        :actor,   # 角色（角色相关）
        :weapon,  # 武器（武器相关）
        :skill,   # 技能（固定为1号技能）
    ]
    def attack_data
      uindex = AttackLoadDataType.index(AttackLoadData[:useablerange])
      dindex = AttackLoadDataType.index(AttackLoadData[:damage])
      func = ->(index, flag, judgefunc) do
        data = nil
        loop do
          data = attack_data_basic(AttackLoadDataType[index])[flag]
          break if (judgefunc.call(data) || index.zero?)
          index -= 1
        end
        return data
      end
      udata = func.call(uindex, :useablerange, ->(data) { !data.values.include?(nil) })
      ddata = func.call(dindex, :damage, ->(data) { data })
      udata[:optional] = udata[:optional].diff(SRPG::Range.post)
      { useablerange: udata, damage: ddata }
    end
    def attack_data_basic(type)
      case type
      when :default
        {
            useablerange: AttackDefaultUseableRange,
            damage:       AttackDefaultDamage
        }
      when :actor
        {
            useablerange: {
                optional: self.note.get_range(:Opt),
                elected:  SRPG::Range.post
            },
            damage:       AttackDefaultDamage
        }
      when :weapon
        {
            useablerange: {
                optional: weapon ? weapon.useable_range.get_range(:optional) : nil,
                elected:  weapon ? weapon.useable_range.get_range(:elected) : nil
            },
            damage:       AttackDefaultDamage
        }
      when :skill
        skill = DataManager.get(:skill,1)
        {
            useablerange: {
                optional: skill.useable_range.get_range(:optional),
                elected:  skill.useable_range.get_range(:elected)
            },
            damage:       skill.damage
        }
      end
    end
  end

  #-------------------------
  # * Class Note
  #-------------------------
  class Note
    attr_reader :data
    def initialize(data)
      putError("Data in Note is not String.") unless data.is_a?(String)
      @data = data
    end
    def get_range(keyword = :Map)
      if (@data =~ /#{keyword} *(\(.*?\))/m)
        return SRPG::Range.match_map($1,0)
      elsif (@data =~ /#{keyword} *: *(.*)/)
        return eval("SRPG::Range." + $1)
      end
    end
    # Dec Data
    def move;  get_dec_data(:MOVE);  end
    def view;  get_dec_data(:VIEW);  end
    def level; get_dec_data(:LEVEL); end

    def animation
      get_dec_data(:animation)
    end
    # Flg Data
    def leader?; get_flg_data(:LEADER); end

    private
    def get_dec_data(*symbols)
      get_datas(symbols,:get_dec_data_basic)
    end
    def get_flg_data(*symbols)
      get_datas(symbols,:get_flg_data_basic)
    end

    def get_dec_data_basic(symbol)
      @data =~ /#{symbol} *: *(\d+)/ ? $1.to_i : nil
    end
    def get_flg_data_basic(symbol)
      @data =~ /#{symbol}/
    end

    def get_datas(syms, methsym)
      result = nil
      syms.each do |sym|
        result ||= send(methsym,sym.upcase)
        result ||= send(methsym,sym.downcase)
      end
      return result
    end
  end

  #-------------------------
  # * Class EventName
  #-------------------------
  class EventName
    # Const
    BattlerDataSymbol = {
        type:   { A: :actor, E: :enemy, F: :friend },
        datype: { A: :actor, E: :enemy }
    }
    BattlerDataConvertSymbol = {
        A:  :AA, E:  :EE, F:  :FA,
        AC: :AA, EM: :EE, PM: :AE
    }
    TypeSymbol = [
        :battler,
        :setpost,
        :obstacle,
        :event
    ]
    SetValueRegexp = {
        level:  [ /LV(\d+)/ ],
        move:   [ /MOV(\d+)/ ],
        view:   [ /VIW(\d+)/ ]
    }
    MarkRegexp = {
        leader:   [ /LEADER/, /LED/, /BOSS/ ]
    }
    TypeRegexp = {
        setpost:  [ /^NUM(\d+)/, /^PE(\d+)/ ],
        obstacle: [ /^OBS/, /^UNPASS/ ],
        event:    [ /^EVENT/ ]
    }
    # Initialize
    def initialize(data)
      @data = data.upcase
    end
    # Get
    def get_type
      return @type if @type
      TypeSymbol.each do |type|
        return @type = type if eval("is_#{type}?")
      end
    end
    def get_record
      @record
    end
    def get_battler(datafunc, listfunc)
      # Get Battler
      if (is_battler?)
        type, datype, id = *@record
        battler = datafunc.call(datype,id)
      elsif (is_setpost?)
        type, datype, id = :actor, :actor, @record
        battler = listfunc.call(id)
      else
        return putError('This Event is Not Battler.')
      end
      # Get Adjust TODO
      note = SRPG::DataManager.get(datype,battler.id).note
      move  = (SetValueRegexp[:move].any? {|e|@data=~e}) ? $1.to_i : note.move
      view  = (SetValueRegexp[:view].any? {|e|@data=~e}) ? $1.to_i : note.view
      level = (SetValueRegexp[:level].any?{|e|@data=~e}) ? $1.to_i : battler.level
      # Set Adjust
      battler.note  = note.data
      battler.move  = move
      battler.view  = view
      battler.level = level
      # Return
      SRPG::Battler.new(battler.id, type, datype, battler)
    end
    # Check
    def is_battler?
      return @type == :battler if @type
      types, datypes = BattlerDataSymbol[:type], BattlerDataSymbol[:datype]
      convs = BattlerDataConvertSymbol
      if (@data =~ /^([#{types.keys.join}])([#{datypes.keys.join}])(\d+)/)
        @record = [types[$1.to_sym], datypes[$2.to_sym], $3.to_i]
        return true
      elsif (convs.keys.any? { |e| @data =~ /^(#{e})(\d+)/ })
        sym = convs[$1.to_sym]
        @record = [types[sym[0].to_sym], datypes[sym[1].to_sym], $2.to_i]
        return true
      end
      return false
    end
    def is_obstacle?
      return @type == :obstacle if @type
      TypeRegexp[:obstacle].any? { |e| @data =~ e }
    end
    def is_setpost?
      return @type == :setpost if @type
      result = TypeRegexp[:setpost].any? { |e| @data =~ e }
      @record = $1.to_i if result
      return result
    end
    def is_event?
      return @type == :event if @type
      TypeRegexp[:event].any? { |e| @data =~ e }
    end
  end

  #-------------------------
  # * Class BattleMap
  #-------------------------
  class BattleMap
    # Include
    include SRPG
    # Attr
    attr_reader :width, :height
    attr_reader :datalist, :settermap, :basepassmap
    # Initialize
    def initialize(data)
      @data = data
      @width, @height = data.width, data.height
      init_data
    end
    def passmap
      passmap = @basepassmap.clone
      @datalist[:obstacle].each { |s| passmap[s.x,s.y] = 0 }
      return passmap
    end
    # Init Data
    def init_data
      init_datalist
      init_settermap
      init_basepassmap
    end
    def init_datalist
      @datalist = SetterDatas.new
      @data.events.each do |ev_id, event|
        evname = EventName.new(event.event.name)
        case evname.get_type
        when :battler, :setpost
          data = evname.get_battler(datafunc,listfunc)
          type = data.type
        when :obstacle, :event
          type = evname.get_type
          data = nil
        else
          next
        end
        @datalist.push(Setter.new(type,ev_id,data))
      end
    end
    def init_settermap
      @settermap = SetterMap.new(@width,@height)
      @datalist.each do |s|
        event = @data.events[s.id]
        @settermap[event.x,event.y] = s
      end
    end
    def init_basepassmap
      @basepassmap = Map.new(@width,@height)
      @basepassmap.set_with_index { |x,y| @data.check_passage(x,y,0xf) ? 1 : 0 }
    end
    #---------------------------
    # Lambdas
    #---------------------------
    def datafunc
      lambda do |datype, id|
        case datype
        when :actor
          $game_actors[id].clone
        when :enemy
          Game_Enemy.new(0,id).clone
        end
      end
    end
    def listfunc
      lambda do |id|
        $game_party.all_members[id-1]
      end
    end
  end

  #-------------------------
  # * Module Move
  #-------------------------
  module Move
    private
    # Kernel
    DirK = [ 1, 2, 3, 4 ]
    # RGSS
    DirR = [ 8, 2, 4, 6 ]
    # Symbol
    DirS = [ :UP, :DOWN, :LEFT, :RIGHT ]

    # Kernel to Symbol
    DirK2S = { 1=>:UP, 2=>:DOWN, 3=>:LEFT, 4=>:RIGHT }
    # Symbol to Kernel
    DirS2K = { UP:1, DOWN:2, LEFT:3, RIGHT:4 }

    # Kernel to RGSS
    DirK2R = { 1=>8, 2=>2, 3=>4, 4=>6 }
    # RGSS to Kernel
    DirR2K = { 8=>1, 2=>2, 4=>3, 6=>4 }

    # RGSS to Symbol
    DirR2S = { 8=>:UP, 2=>:DOWN, 4=>:LEFT, 6=>:RIGHT }
    # Symbol to RGSS
    DirS2R = { UP:8, DOWN:2, LEFT:4, RIGHT:6 }
  end
end

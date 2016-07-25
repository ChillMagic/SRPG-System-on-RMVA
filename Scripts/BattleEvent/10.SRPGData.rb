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
    # TODO
    def get_attack_data
      Data::Attack.new(attack_data)
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
                elected:  self.note.get_range(:Elt)
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
  end
  
  class Note
    attr_reader :data
    def initialize(data)
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
  
  module EventName
    # Const
    CovType = {
      A:  :AA, E:  :EE, F:  :FA,
      AC: :AA, EM: :EE, PM: :AE
    }
    KeyType = {
      type:   { A: :actor, E: :enemy, F: :friend },
      datype: { A: :actor, E: :enemy }
    }
    SetType = {
      level:  [ /LV(\d+)/ ],
      move:   [ /MOV(\d+)/ ],
      view:   [ /VIW(\d+)/ ]
    }
    SpeType = {
      leader:   [ /LEADER/, /LED/, /BOSS/ ],
      position: [ /NUM(\d+)/, /PE(\d+)/ ],
      obstacle: [ /OBS/, /UNPASS/ ]
    }
    # Method
    def self.get_position(name)
      SpeType[:position].any? { |e| name =~ e }
      return $1.to_i
    end
    def self.get_battler(name)
      # Get Data
      name = name.upcase
      if ((id = get_position(name)) != 0)
        type    = :actor
        datype  = :actor
        battler = $game_party.all_members[id-1]
      else
        tyname = (name[1] =~ /\d/) ? name[0] : name[0,2]
        tyname = CovType[tyname.to_sym].to_s if CovType[tyname.to_sym]
        type   = KeyType[:type][tyname[0].to_sym]
        datype = KeyType[:datype][tyname[1].to_sym]
        return unless (type && datype && name =~ /#{name[0,2]}(\d+)/)
        case (datype)
        when :actor
          battler = $game_actors[$1.to_i].clone
        when :enemy
          battler = Game_Enemy.new(0,$1.to_i).clone
        end
      end
      return if battler.nil?
      # Get Note
      note = get_note(datype,battler)
      battler.note  = note
      # Get Adjust
      move  = (SetType[:move].any? {|e|name=~e}) ? $1.to_i : note.move
      view  = (SetType[:view].any? {|e|name=~e}) ? $1.to_i : note.view
      level = (SetType[:level].any?{|e|name=~e}) ? $1.to_i : battler.level
      # Set Adjust
      battler.move  = move
      battler.view  = view
      battler.level = level
      # Return
      return SRPG::Battler.new(battler.id, type, datype, battler)
    end
    def self.get_passage(name)
      SpeType[:obstacle].any? { |e| name =~ e }
    end
    def self.get_note(type, battler)
      SRPG::DataManager.get(type,battler.id).note
    end
  end
  

  module MapData
    include SRPG
    # Set SetterMap
    def self.get_settermap
      map = SetterMap.new(wx,wy)
      datalist = SetterDatas.new
      $game_map.events.each do |ev_id,event|
        name   = event.event.name
        # TODO : Create a function include these.
        battler = EventName.get_battler(name)
        next if battler.nil?
        setter  = Setter.new(battler.type,ev_id,battler)
        map[event.x, event.y] = setter
        datalist.push(setter)
      end
      [map, datalist]
    end
    def self.get_passmap
      map = SRPG::Map.new(wx,wy)
      map.set_with_index { |x,y| $game_map.check_passage(x,y,0xf) ? 1 : 0 }
      $game_map.events.each_value do |event|
        name = event.event.name
        map[event.x, event.y] = 0 if (EventName.get_passage(name))
      end
      return map
    end
    def self.get_passage(x, y)
      $game_map.get_passage_data(x,y)
    end

    private
    def self.wx
      $game_map.width
    end
    def self.wy
      $game_map.height
    end
  end

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

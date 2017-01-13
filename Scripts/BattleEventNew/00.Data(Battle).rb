module SRPG
  module Data
    module UseableRangeModule
      #--------------------------------
      # * Damage
      #--------------------------------
      class Damage
        include Reference
        DamageType = [
            :none,        # None
            :hp_damage,   # HP Damage
            :mp_damage,   # MP Damage
            :hp_recover,  # HP Recover
            :mp_recover,  # MP Recover
        ]
        attr_accessor :type
        attr_reference :element_id, :formula, :variance, :critical
      end
      #------------------------------
      # + UseableRange
      #------------------------------
      class UseableRange
        # Attr
        attr_reader :rantype, :efftype  # Type
        # Const
        RangeType  = [
            :none,   # None
            :self,   # Self
            :indiv,  # Individual
            :range,  # Range
            :direct, # direction
            :whole,  # Whole
        ]
        EffectType = [
            :none,   # None
            :party,  # Party
            :enemy,  # Enemy
            :blank,  # Blank
        ]
        # Initialize
        def initialize(types, ranges)
          @rantype = types[0]
          @efftype = types[1]
          init_range(@rantype, ranges)
        end
        def init_range(type, ranges)
          case type
          when :none
            optional = elected = SRPG::Range.new
          when :self
            optional = elected = SRPG::Range.post
          when :indiv
            optional = ranges[:optional]
            elected = SRPG::Range.post
          when :range
            optional = ranges[:optional]
            elected  = ranges[:elected]
          when :direct
            optional = ranges[:optional]
            elected  = ranges[:elected]
          when :whole
            optional = SRPG::Range.whole
            elected  = ranges[:elected]
          else
            return putError("Not Find Type(#{type}) in RangeType.")
          end
          @ranges = Hash.new
          @ranges[:optional] = optional
          @ranges[:elected]  = elected
        end
        def get_range(flag, post = nil)
          @ranges[flag] ||= SRPG::Range.new
          post.nil? ? @ranges[flag] : @ranges[flag].move(*post)
        end
        def moved_range(cp, tp)
          MovedRange.new(@ranges[:optional].move(*cp), @ranges[:elected].move(*tp))
        end
        class MovedRange < Struct.new(:optional,:elected)
          def check_in(x, y)
            self.optional.include?(x,y)
          end
          def check_each
            self.elected.each { |x, y| return true if yield(x,y) }
            return false
          end
        end
      end
      def useable_range
        type = useable_range_type_data
        ranges = { optional: optional_range_data, elected: elected_range_data }
        UseableRange.new(type,ranges)
      end
      def optional_range(pos = nil)
        useable_range.get_range(:optional,pos)
      end
      def elected_range(pos = nil)
        useable_range.get_range(:elected,pos)
      end
      private
      def useable_range_type_data; end
      def optional_range_data; end
      def elected_range_data;  end
    end

    #--------------------------------
    # * Class BaseItem
    #--------------------------------
    class BaseItem < BaseData
      include UseableRangeModule
      attr_reference :id
      def note
        Note.new(@data.note)
      end
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
    class Attack < BaseItem
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

    #--------------------------------
    # * Class Equip
    #--------------------------------
    class Equip < BaseData
      attr_reference :id
      attr_reference :animation_id
      def note
        Note.new(@data.note)
      end
    end
    class Weapon < BaseItem
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
    class Armor < Equip
    end
    #--------------------------------
    # * Others
    #--------------------------------
    # TODO
    class Skill < BaseItem; end
    class Item < BaseItem; end

    #-------------------------
    # * Class Battler
    #-------------------------
    class Battler
      include SRPG
      include Config
      #------------------
      # + Attr Reference
      #------------------
      attr_reference :name, :nickname, :face_name, :face_index
      attr_reference :state_icons, :buff_icons
      attr_reference :hp_rate, :mp_rate, :max_level?, :exp, :next_level_exp
      attr_reference :description, :class
      attr_referencefun :param
      #------------------
      # + UseableRange
      #------------------
      def get_attack_data
        @attack_data ||= Data::Attack.new(attack_data)
      end
      def get_skill_data(id = nil)
        id.nil? ? @skills.collect { |id| DataManager.get(:skill,id) } : DataManager.get(:skill, id)#@skills[id])
      end
      def attack_optional_range(pos = nil)
        get_attack_data.useable_range.get_range(:optional,pos)
      end
      def attack_elected_range(pos = nil)
        get_attack_data.useable_range.get_range(:elected,pos)
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
    class Actor < Battler; end
    class Enemy < Battler; end

    class State < BaseData; end

  end
end

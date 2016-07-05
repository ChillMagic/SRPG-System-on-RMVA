#=================================================
# SRPG::BaseItem
#-------------------------------------------------
# Update : 06/25/2016
#=================================================

module SRPG
  module Data
    #--------------------------------
    # * Damage
    #--------------------------------
    class Damage
      include Reference
      attr_reference :type, :element_id, :formula, :variance, :critical
    end
    #------------------------------
    # + UseableRange
    #------------------------------
    class UseableRange
      #--------
      # + New
      #--------
      RangeData = Struct.new(:optional, :elected)
      def initialize(optional, elected)
        @ranges = RangeData.new(optional, elected)
      end
      def get_range(flag)
        @ranges[flag]
      end
      def check_in(x, y)
        @ranges[:optional].include?(x, y)
      end
      def check_each
        @ranges[:elected].each { |x, y| return true if yield(x,y) }
        return false
      end
      #--------
      # + Old
      #--------
      # # Attr
      # attr_reader :atktype, :rantype, :ranges
      # # Const
      # EffectType = [
      #     :self,  # Self
      #     :enemy, # Enemy
      #     :party, # Party
      # ]
      # RangeType  = [
      #     :none,  # None
      #     :self,  # Self
      #     :indiv, # Individual
      #     :range, # Range
      # ]
      # RangeData = Struct.new(:optional,:elected)
      # # Initialize
      # def initialize(efftype, rantype, *ranges)
      #   @efftype, @rantype = efftype, rantype
      #   @ranges = get_ranges(type,ranges)
      # end
      # # Function
      # def get_ranges(type, ranges)
      #   putError("Not find type(#{type}) in UseableRange.") unless (RangeType.include?(type))
      #   case type
      #   when :self
      #     optional = Range.range(0)
      #     elected  = Range.range(0)
      #   when :indiv
      #     optional = ranges.first
      #     elected  = Range.range(0)
      #   when :range
      #     optional = Range.range(0)
      #     elected  = ranges.last
      #   end
      #   RangeData.new(optional,elected)
      # end
    end
    #--------------------------------
    # * BaseItem
    #--------------------------------
    class BaseItem < BaseData
      attr_reference :id
      def damage; Damage.new(@data.damage); end
      def range(r1, r2); UseableRange.new(r1,r2); end
    end
    #--------------------------------
    # * Others
    #--------------------------------
    # TODO
    class Attack < BaseItem
      def initialize(attack_range)
        @attack_range = attack_range
      end
      def range(curr_post = [0,0], targ_post = [0,0])
        opt_range = @attack_range.move(*curr_post)
        # TODO
        elt_range = SRPG::Range.new([[*targ_post]])
        return super(opt_range,elt_range)
      end
    end
    class Skill < BaseItem; end
    class Item < BaseItem; end

    class Actor < Battler; end
    class Enemy < Battler; end

    class Equip < BaseData; end
    class Weapon < Equip; end
    class Armor < Equip; end

    class State < BaseData; end
  end
end

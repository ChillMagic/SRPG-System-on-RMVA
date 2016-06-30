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
      # Attr
      attr_reader :atktype, :rantype, :ranges
      # Const
      EffectType = [
          :self,  # Self
          :enemy, # Enemy
          :party, # Party
      ]
      RangeType  = [
          :none,  # None
          :self,  # Self
          :indiv, # Individual
          :range, # Range
      ]
      RangeData = Struct.new(:optional,:elected)
      # Initialize
      def initialize(efftype, rantype, *ranges)
        @efftype, @rantype = efftype, rantype
        @ranges = get_ranges(type,ranges)
      end
      # Function
      def get_ranges(type, ranges)
        putError("Not find type(#{type}) in UseableRange.") unless (RangeType.include?(type))
        case type
        when :self
          optional = Range.range(0)
          elected  = Range.range(0)
        when :indiv
          optional = ranges.first
          elected  = Range.range(0)
        when :range
          optional = Range.range(0)
          elected  = ranges.last
        end
        RangeData.new(optional,elected)
      end
    end
    #--------------------------------
    # * BaseItem
    #--------------------------------
    class BaseItem < BaseData
      attr_reference :id
      def damage; Damage.new(@data.damage); end
      def range; UseableRange.new(0,0); end
    end
    #--------------------------------
    # * Others
    #--------------------------------
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

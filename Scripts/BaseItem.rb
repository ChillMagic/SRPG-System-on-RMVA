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
    module UseableRangeModule
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
    # * BaseItem
    #--------------------------------
    class BaseItem < BaseData
      include UseableRangeModule
      attr_reference :id
      def note
        Note.new(@data.note)
      end
      def damage
        Damage.new(@data.damage)
      end
    end
    #--------------------------------
    # * Others
    #--------------------------------
    # TODO
    class Attack < BaseItem; end
    class Skill < BaseItem; end
    class Item < BaseItem; end

    class Actor < Battler; end
    class Enemy < Battler; end

    #--------------------------------
    # * Equip
    #--------------------------------
    class Equip < BaseData
      attr_reference :id
      attr_reference :animation_id
      def note
        Note.new(@data.note)
      end
    end
    class Weapon < Equip
      include UseableRangeModule
    end
    class Armor < Equip; end

    class State < BaseData; end
  end
end

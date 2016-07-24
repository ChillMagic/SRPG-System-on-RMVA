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
    # class UseableRange
    #   #--------
    #   # + New
    #   #--------
    #   RangeData = Struct.new(:optional, :elected)
    #   def initialize(optional, elected)
    #     @ranges = RangeData.new(optional, elected)
    #   end
    #   def get_range(flag)
    #     @ranges[flag]
    #   end
    #   def check_in(x, y)
    #     @ranges[:optional].include?(x, y)
    #   end
    #   def check_each
    #     @ranges[:elected].each { |x, y| return true if yield(x,y) }
    #     return false
    #   end
    # end
    UseableRange = SRPG::NewData::UseableRange
    #--------------------------------
    # * BaseItem
    #--------------------------------
    class BaseItem < BaseData
      attr_reference :id
      def note; Note.new(@data.note); end
      def damage; Damage.new(@data.damage); end
      def useable_range_type; end
      def useable_range
        UseableRange.new(useable_range_type,{:optional=>optional_range,:elected=>elected_range})
      end
      def range(cp, tp); useable_range.moved_range(cp,tp) end
      private
      def optional_range; end
      def elected_range;  end
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

    class Equip < BaseData; end
    class Weapon < Equip; end
    class Armor < Equip; end

    class State < BaseData; end
  end
end

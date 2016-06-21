#=================================================
# SRPG::Data
#-------------------------------------------------
# Update : 05/15/2015
#=================================================

module SRPG
  module Data
    #------------------------------
    # + MatchMap
    #------------------------------
    module MatchMap
      # Match Map Data
      def self.matchMap(string, count_p = 1)
        # Basic String
        str = string[/\((.*)\)/m,1]
        return putError('Could not Match Map.') if (str.nil?)
        str = str.strip.delete(" ").delete("\r").squeeze("\n")
        # Set Record Data
        line = 1
        count = 0
        record = 0
        data = Array.new
        # Match
        str.each_char do |c|
          case c
            when "\n"
              line += 1
              next
            when "P"
              data.push(count_p)
              record = count
            else
              data.push(c.to_i)
          end
          count += 1
        end
        # Check
        putError("Error in Match of Map.") if (count % line != 0)
        # Set Map
        map = SRPG::Map.new(count/line,line,data)
        px, py = map.point(record)
        return [map, px, py]
      end
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
    # * Structs
    #--------------------------------
    SelectAction = Struct.new(:type, :id)
    SelectObject = Array
    #--------------------------------
    # * Damage
    #--------------------------------
    Damage = Struct.new(:type, :element_id, :formula, :variance, :critical) do
      def initialize(damage)
        self.type       = damage.type
        self.element_id = damage.element_id
        self.formula    = damage.formula
        self.variance   = damage.variance
        self.critical   = damage.critical
      end
    end
  end
end

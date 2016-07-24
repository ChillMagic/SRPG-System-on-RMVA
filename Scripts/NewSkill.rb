module SRPG
  module NewData
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
    class Skill

    end
  end
end

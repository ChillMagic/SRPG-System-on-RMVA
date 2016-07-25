module SRPG
  #--------------------------------
  # * Module AI
  #--------------------------------
  module AI
    #------------------------------
    # - Range Calculator
    #    Variables Name :
    #     mr : Move Range
    #     ar : Attack Range
    #     br : Attack Basic Range
    #     sr : Select Range
    #------------------------------
    def self.distance(x1, y1, x2, y2)
      (x1-x2).abs + (y1-y2).abs
    end
    def self.get_attack_range(mr, br)
      ar = Range.new
      mr.each { |x,y| ar.union!(br.move(x,y)) }
      return ar
    end
    def self.get_attack_point(move_route, mr, br, tx, ty)
      data = Array.new
      mr.each do |x,y|
        evaluate = move_route.get_path(x,y).size
        data.push([evaluate,[x,y]]) if br.move(x,y).include?(tx,ty)
      end
      return data.empty? ? nil : data.min.last
    end

    #------------------------------
    # + Function
    #------------------------------
    def self.make_skill_damage(user, target, variables, string)
      a = user
      b = target
      v = variables
      begin
        eval(string)
      rescue Exception => res
        putError("Calculator Error in #{self.class}(#{string}) " +
                     "for #{a.class}(#{a.id}), #{b.class}(#{b.id}).\n>  " + res.to_s)
      end
    end

    #------------------------------
    # + Evaluate
    #------------------------------
    # Single conflict
    DamageEvaluate  = Struct.new(:type, :damage, :add_status)
    BattlerStateKey = [
      :low_hp,
      :low_mp,
      :debuff,
      :surrounded,
    ]
    class BattlerState < Struct.new(*BattlerStateKey)
      # def =(a)
      #   p [:SYM,a]
      # end
    end
   # BattlerState.new = 4

    #------------------------------
    # + Function
    #------------------------------
    def self.min(*args)
      args.min
    end
    def self.max(*args)
      args.max
    end
    def self.rand(a, b)
      a + Kernel.rand(b - a + 1)
    end
  end
end

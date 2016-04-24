#=================================================
# SRPG::BaseItem
#-------------------------------------------------
# Update : 02/26/2016
#=================================================

module SRPG
  class BaseItem
    def initialize
    end
    def make_skill_damage(user, target, variables, string)
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
  end
end

# Game_Battler = Struct.new(:atk, :def, :id)
# a = Game_Battler.new(5,6,1)
# b = Game_Battler.new(10,0,2)
# string = "a-b"
# v = Array.new(500,0)
# p SRPG::Skill.new.make_skill_damage(a, b, v, string)
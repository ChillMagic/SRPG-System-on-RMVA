#=================================================
# SRPG::Battle
#-------------------------------------------------
# Update : 12/03/2015
#=================================================

=begin
  SRPG::Data::Battler -> SRPG::Battler
=end

# TODO : SRPG::Battler, the basic class of battlers.
module SRPG
  # #--------------------------------
  # # * Class Status
  # #--------------------------------
  # class Status
  #   def initialize
  #     @status = Array.new
  #   end
  #   def add(status)
  #     # TODO
  #     @status.push(status)
  #   end
  #   def clear
  #     @status.clear
  #   end
  # end

  #--------------------------------
  # * Class Data::Skill
  #--------------------------------
  class Data::Skill
    attr_reader :id
    def initialize(id)
    end
  end
end
# Graphics.frame_rate = 30














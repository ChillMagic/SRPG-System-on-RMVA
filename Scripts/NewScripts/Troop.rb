require_relative 'Set'

module SRPG
  class Troop
    def initialize
      @data = Set.new(SRPG::Battler)
    end
  end
end

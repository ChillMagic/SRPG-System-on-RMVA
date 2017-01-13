# Main Interface

require_relative 'System'
require_relative 'Data/Battler'
require_relative 'Battler'

module SRPG
  class Set
    def initialize(type)
      Chill.checkSingleType(__LINE__, self.class, __method__, Class, type)
      @type = type
      @data = Array.new
    end
    def push(*args)
      Chill.checkSingleTypes(__LINE__, self.class, __method__, @type, args)
      @data.push(*args)
    end
    def pop
      @data.pop
    end
  end
end

module SRPG
  class Troop
    def initialize
      @data = Set.new(SRPG::Battler)
    end
  end
end

def __main__
  troop = SRPG::Set.new(SRPG::Battler) #SRPG::Troop.new
  troop.push(SRPG::Battler.new(0,1,SRPG::Data::Battler.new))
end

__main__

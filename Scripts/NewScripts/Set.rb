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

module SRPG
  #-------------------------
  # * Class BattleMap
  #-------------------------
  class BattleMap
    # Include
    include SRPG
    # Attr
    attr_reader :width, :height
    attr_reader :datalist, :settermap, :basepassmap
    # Initialize
    def initialize(data, datafunc, listfunc)
      @data = data
      @width, @height = data.width, data.height
      init_data(datafunc, listfunc)
    end
    def passmap
      passmap = @basepassmap.clone
      @datalist[:obstacle].each { |s| passmap[s.x,s.y] = 0 }
      return passmap
    end
    #---------------------------
    # * Self Method
    #---------------------------
    def get_passmap(types)
      passmap = self.passmap
      types.each { |type| @datalist[type].each { |s| passmap[s.x,s.y] = 0 } }
      return passmap
    end
    def get_range_of_setter(types = nil)
      if (types)
        array = types.collect { |type| @datalist[type].collect { |s| [s.x, s.y] } }.flatten
      else
        array = @datalist.collect { |s| [s.x, s.y] }
      end
      Range.new(array)
    end
    def reset_status
      @settermap.each { |e| e.status.reset }
    end
    def include_type?(range, types)
      types = [types] unless types.is_a?(Array)
      range.each { |x,y| return true if types.include?(self[x,y].type) }
      return false
    end
    def without_type?(range, types)
      types = [types] unless types.is_a?(Array)
      range.each { |x,y| return false if types.include?(self[x,y].type) }
      return true
    end
    #---------------------------
    # * BaseMap Method
    #---------------------------
    def terrain_tag(x, y)
      @data.terrain_tag(x, y)
    end
    def region_id(x, y)
      @data.region_id(x, y)
    end
    def check_passage(x, y, bit)
      @data.check_passage(x,y,bit)
    end
    #---------------------------
    # * SetterMap Method
    #---------------------------
    def [](x, y)
      @settermap[x,y]
    end
    def out?(x, y)
      @settermap.out?(x,y)
    end
    def each(&block)
      @settermap.each(&block)
    end
    def each_index(&block)
      @settermap.each_index(&block)
    end
    def chrecord
      @settermap.chrecord
    end
    #---------------------------
    # * Initialize Data
    #---------------------------
    private
    # Init Data
    def init_data(datafunc, listfunc)
      init_datalist(datafunc, listfunc)
      init_settermap
      init_basepassmap
    end
    def init_datalist(datafunc, listfunc)
      @datalist = SetterDatas.new
      @data.events.each do |ev_id, event|
        evname = Data::EventName.new(event.event.name)
        case evname.get_type
        when :battler, :setpost
          data = evname.get_battler(datafunc,listfunc)
          type = data.type
        when :obstacle, :event
          type = evname.get_type
          data = nil
        else
          next
        end
        @datalist.push(Setter.new(type,ev_id,data))
      end
    end
    def init_settermap
      @settermap = SetterMap.new(@width,@height)
      @datalist.each do |s|
        event = @data.events[s.id]
        @settermap[event.x,event.y] = s
      end
    end
    def init_basepassmap
      @basepassmap = Map.new(@width,@height)
      @basepassmap.set_with_index { |x,y| @data.check_passage(x,y,0xf) ? 1 : 0 }
    end
  end
end

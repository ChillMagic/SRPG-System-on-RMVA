module SRPG

  # BattleMap

  class BattleMap
    include Data
    def initialize(data)
      @data = data
      w, h = data.width, data.height
      @basemap = Map.new(w, h)
      @settermap = SetterMap.new(w, h)
    end
    def init_basemap
      @basemap.set_with_index { |x,y| check_passage(x,y,0xf) ? 1 : 0 }
      events.each_value do |event|
        name = event.event.name

        map[event.x, event.y] = 0 if (EventName.new(name).is_obstacle?)
      end
    end
    def get_datalist
      datalist = SetterDatas.new
      events.each do |ev_id, event|
        name   = event.event.name
        setter = Setter.new(type,ev_id,data)
        datalist.push(setter)
      end
    end
    def get_settermap

    end
    def events
      @data.events
    end
    def terrain_tag(x, y)
      @data.terrain_tag(x, y)
    end
    def region_id(x, y)
      @data.region_id(x, y)
    end
    def check_passage(x, y, bit)
      @data.check_passage(x,y,bit)
    end
  end
end

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
      events.each do |ev_id,event|
        name   = event.event.name
        # TODO : Create a function include these.
        battler = EventName.new(name).get_battler(->(*args){datafunc(*args)},->(*args){listfunc(*args)})
        next if battler.nil?
        setter  = Setter.new(battler.type,ev_id,battler)
        set_setter(map, datalist, event.x, event.y, Setter.new(battler.type,ev_id,battler))
      end
      [map, datalist]
    end

    def datafunc(datype, id)
      case datype
      when :actor
        $game_actors[id].clone
      when :enemy
        Game_Enemy.new(0,id).clone
      end
    end
    def listfunc(id)
      $game_party.all_members[id-1]
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

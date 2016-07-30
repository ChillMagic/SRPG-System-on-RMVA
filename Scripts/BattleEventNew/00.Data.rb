
module SRPG::Data
  include SRPG

  # Initialze

  def self.init
    # Init DataManager
    dls = DataManager::DataLists.new
    dls.add(:actor,  Actor,  $data_actors)
    dls.add(:enemy,  Enemy,  $data_enemies)
    dls.add(:class,  Class,  $data_classes)
    dls.add(:skill,  Skill,  $data_skills)
    dls.add(:item,   Item,   $data_items)
    dls.add(:weapon, Weapon, $data_weapons)
    dls.add(:armor,  Armor,  $data_armors)
    dls.add(:state,  State,  $data_states)
    dls.add_func(:variables, lambda{$game_variables})
    DataManager.init(dls)
  end

  class EventName
    # Const
    BattlerDataSymbol = {
        type:   { A: :actor, E: :enemy, F: :friend },
        datype: { A: :actor, E: :enemy }
    }
    BattlerDataConvertSymbol = {
        A:  :AA, E:  :EE, F:  :FA,
        AC: :AA, EM: :EE, PM: :AE
    }
    TypeSymbol = [
        :battler,
        :setpost,
        :obstacle,
        :event
    ]
    SetValueRegexp = {
        level:  [ /LV(\d+)/ ],
        move:   [ /MOV(\d+)/ ],
        view:   [ /VIW(\d+)/ ]
    }
    MarkRegexp = {
        leader:   [ /LEADER/, /LED/, /BOSS/ ]
    }
    TypeRegexp = {
        setpost:  [ /^NUM(\d+)/, /^PE(\d+)/ ],
        obstacle: [ /^OBS/, /^UNPASS/ ],
        event:    [ /^EVENT/ ]
    }
    # Initialize
    def initialize(data)
      @data = data.upcase
    end
    # Get
    def get_type
      return @type if @type
      TypeSymbol.each do |type|
        return @type = type if eval("is_#{type}?")
      end
    end
    def get_record
      @record
    end
    def get_battler(datafunc, listfunc)
      if (is_battler?)
        type, datype, id = *@record
        battler = datafunc.call(datype,id)
      elsif (is_setpost?)
        type, datype, id = :actor, :actor, @record
        battler = listfunc.call(id)
      else
        return putError('This Event is Not Battler.')
      end
      SRPG::Battler.new(battler.id, type, datype, battler)
    end
    # Check
    def is_battler?
      return @type == :battler if @type
      types, datypes = BattlerDataSymbol[:type], BattlerDataSymbol[:datype]
      convs = BattlerDataConvertSymbol
      if (@data =~ /^([#{types.keys.join}])([#{datypes.keys.join}])(\d+)/)
        @record = [types[$1.to_sym], datypes[$2.to_sym], $3.to_i]
        return true
      elsif (convs.keys.any? { |e| @data =~ /^(#{e})(\d+)/ })
        sym = convs[$1.to_sym]
        @record = [types[sym[0].to_sym], datypes[sym[1].to_sym], $2.to_i]
        return true
      end
      return false
    end
    def is_obstacle?
      return @type == :obstacle if @type
      TypeRegexp[:obstacle].any? { |e| @data =~ e }
    end
    def is_setpost?
      return @type == :setpost if @type
      result = TypeRegexp[:setpost].any? { |e| @data =~ e }
      @record = $1.to_i if result
      return result
    end
    def is_event?
      return @type == :event if @type
      TypeRegexp[:event].any? { |e| @data =~ e }
    end
  end

  module Move
    private
    # Kernel
    DirK = [ 1, 2, 3, 4 ]
    # RGSS
    DirR = [ 8, 2, 4, 6 ]
    # Symbol
    DirS = [ :UP, :DOWN, :LEFT, :RIGHT ]

    # Kernel to Symbol
    DirK2S = { 1=>:UP, 2=>:DOWN, 3=>:LEFT, 4=>:RIGHT }
    # Symbol to Kernel
    DirS2K = { UP:1, DOWN:2, LEFT:3, RIGHT:4 }

    # Kernel to RGSS
    DirK2R = { 1=>8, 2=>2, 3=>4, 4=>6 }
    # RGSS to Kernel
    DirR2K = { 8=>1, 2=>2, 4=>3, 6=>4 }

    # RGSS to Symbol
    DirR2S = { 8=>:UP, 2=>:DOWN, 4=>:LEFT, 6=>:RIGHT }
    # Symbol to RGSS
    DirS2R = { UP:8, DOWN:2, LEFT:4, RIGHT:6 }
  end
end

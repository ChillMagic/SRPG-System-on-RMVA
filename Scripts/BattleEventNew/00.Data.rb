module SRPG
  module Data
    #-------------------------
    # * Initialze
    #-------------------------
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

    #-------------------------
    # * Color
    #-------------------------
    module Color
      Blue    = 0  # 蓝色
      Orange  = 1  # 橙色
      Red     = 2  # 红色
      Celeste = 3  # 青色
      Green   = 4  # 绿色
      Gray    = 5  # 灰色
    end

    #-------------------------
    # * Class EventName
    #-------------------------
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
        # Get Battler
        if (is_battler?)
          type, datype, id = *@record
          battler = datafunc.call(datype,id)
        elsif (is_setpost?)
          type, datype, id = :actor, :actor, @record
          battler = listfunc.call(id)
        else
          return putError('This Event is Not Battler.')
        end
        # Get Adjust TODO
        note  = SRPG::DataManager.get(datype,battler.id).note
        move  = (SetValueRegexp[:move].any? {|e|@data=~e}) ? $1.to_i : note.move
        view  = (SetValueRegexp[:view].any? {|e|@data=~e}) ? $1.to_i : note.view
        level = (SetValueRegexp[:level].any?{|e|@data=~e}) ? $1.to_i : battler.level
        # Set Adjust
        battler.note  = note.data
        battler.move  = move
        battler.view  = view
        battler.level = level
        # Return
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

    #-------------------------
    # * Class Note
    #-------------------------
    class Note
      attr_reader :data
      def initialize(data)
        putError("Data in Note is not String.") unless data.is_a?(String)
        @data = data
      end
      def get_range(keyword = :Map)
        if (@data =~ /#{keyword} *(\(.*?\))/m)
          return SRPG::Range.match_map($1,0)
        elsif (@data =~ /#{keyword} *: *(.*)/)
          return eval("SRPG::Range." + $1)
        end
      end
      # Dec Data
      def move;  get_dec_data(:MOVE);  end
      def view;  get_dec_data(:VIEW);  end
      def level; get_dec_data(:LEVEL); end

      def animation
        get_dec_data(:animation)
      end
      # Flg Data
      def leader?; get_flg_data(:LEADER); end

      private
      def get_dec_data(*symbols)
        get_datas(symbols,:get_dec_data_basic)
      end
      def get_flg_data(*symbols)
        get_datas(symbols,:get_flg_data_basic)
      end

      def get_dec_data_basic(symbol)
        @data =~ /#{symbol} *: *(\d+)/ ? $1.to_i : nil
      end
      def get_flg_data_basic(symbol)
        @data =~ /#{symbol}/
      end

      def get_datas(syms, methsym)
        result = nil
        syms.each do |sym|
          result ||= send(methsym,sym.upcase)
          result ||= send(methsym,sym.downcase)
        end
        return result
      end
    end

    #-----------------------------
    # * Class TempSprite
    #-----------------------------
    class TempSprite < Sprite
      def initialize(bitmap)
        super()
        self.bitmap = bitmap
        self.x = (Graphics.width  - bitmap.width)  / 2
        self.y = (Graphics.height - bitmap.height) / 2
        self.opacity = 0
        @state = :showing
        @count = 20
      end
      def update
        case @state
        when :showing
          if (self.opacity < 255)
            self.opacity += 20
          else
            @state = :waiting
          end
        when :waiting
          @count -= 1
          @state = :hiding if (@count == 0)
        when :hiding
          if (self.opacity > 0)
            self.opacity -= 20
          else
            @state = :over
          end
        end
      end
      def over?
        return @state == :over
      end
    end

    #-------------------------
    # * Module Move
    #-------------------------
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
end

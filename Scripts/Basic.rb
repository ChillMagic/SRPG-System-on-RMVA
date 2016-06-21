#=================================================
# SRPG Basic Const Variables
#-------------------------------------------------
# Update : 01/06/2015
#=================================================

module SRPG
  # Direction
  module Direction
    Wait  = 0
    Up    = 1
    Down  = 2
    Left  = 3
    Right = 4

    private
    InfoMap = {
        Wait  => [ :wait,  Wait  ],
        Up    => [ :up,    Down  ],
        Down  => [ :down,  Up    ],
        Left  => [ :left,  Right ],
        Right => [ :right, Left  ]
    }
    def dir_symbol(dir)
      InfoMap[dir].nil? ? dir : InfoMap[dir][0]
    end
    def dir_opposite(dir)
      InfoMap[dir].nil? ? dir : InfoMap[dir][1]
    end
    def dir_move(dir, x, y)
      case dir
        when Wait;  [x, y]
        when Up;    [x, y - 1]
        when Down;  [x, y + 1]
        when Left;  [x - 1, y]
        when Right; [x + 1, y]
        else
          putError("No direction of #{dir}.")
      end
    end
    def dir_find_symbol(sym)
      InfoMap.each_pair { |key,value| return key if (sym == value[0]) }
      Wait
    end
    def dir_get(dat)
      (dat.is_a?(Fixnum)) ? dat : dir_find_symbol(dat)
    end
  end
  # Flag
  module Flag
    private
    # Const Variables
    Flag = {
      blank:  0,
      actor:  1,
      enemy:  2,
      friend: 3,
      event:  4,
      other:  5,
    }
    FlagName = {
        blank:  "Bl",
        actor:  "Ac",
        enemy:  "En",
        friend: "Fr",
        event:  "Ev",
        other:  "Ot"
    }
    def flag_opposite(flag)
      case flag
        when :actor || :friend
          :enemy
        when :enemy
          :actor
        else
          flag
      end
    end
    def flag_id(flag)
      Flag[flag]
    end
    def flag_symbol(flag)
      putError("The method(#{__method__}) will be deleted.")
      FlagName[flag].nil? ? :other : FlagName[flag]
    end
    def flag_find_symbol(sym)
      putError("The method(#{__method__}) will be deleted.")
      Flag.each_pair { |key,value| return key if (sym == value) }
      :blank
    end
    def flag_get(dat)
      putError("The method(#{__method__}) will be deleted.")
      (dat.is_a?(Fixnum)) ? dat : flag_find_symbol(dat)
    end
    def flag_name(flag)
      Flag[flag].nil? ? "Na" : FlagName[flag]
    end
  end
  # RangeKind
  module RangeKind
    MoveRange = 0 # Move
    AttkRange = 1 # Attack
    BuffRange = 2 # Buff
    SubsRange = 3 # Substitute
  end
  module MoveKey
    MoveKey = {
      :UP    => 1,
      :DOWN  => 2,
      :LEFT  => 3,
      :RIGHT => 4,
    }
    def move_with(direction, x, y)
      direction = MoveKey[direction] if direction.is_a?(Symbol)
      SRPG::Route.dirMove(direction,x,y)
    end
    def move_key
      MoveKey.keys
    end
  end
  module Geometry
    private
    def cir_point(x, y, turn)
      case turn
        when   +0; [+x, +y]
        when  +90; [-y, +x]
        when +180; [-x, -y]
        when +270; [+y, -x]
        else
          putError('Error in method ' + __method__ + '.')
      end
    end
  end
  # Output
  module Output
    def self.list_to_s(list)
      s = ""
      list.each_with_index { |e,i| s << ((i == 0) ? "" : ", ") << e.to_s }
      s
    end
    def self.array_to_s(array)
      "[" << list_to_s(array) << "]"
    end
  end
  # DataPush
  module DataPush
    # Using 'push_basic' to build 'push' method.
    def push(*data)
      data.each { |dat| push_basic(dat) }
      self
    end
    def init_data(data)
      data.each { |d| push_basic(d) } if (data)
    end
  end
end

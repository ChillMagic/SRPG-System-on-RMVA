#=================================================
# SRPG::Setter
#-------------------------------------------------
# Update : 02/25/2016
#=================================================

module SRPG
  #-------------------------------------------------
  # Class Setter
  #-------------------------------------------------
  class Setter
    include Direction
    include Flag
    # Reader
    attr_reader :id, :type, :data
    attr_reader :x, :y, :map
    # Initialize
    def initialize(type = :blank, id = 0, data = nil)
      @id = id
      @data = data
      @type  = type
    end
    # Set Data
    def setMap(map);     @map   = map;   self end
    def setPost(x, y);   @x, @y = x, y;  self end
    # Method
    def blank?; @type == :blank               end
    def clear;  initialize; @map.changeRecord end
    def to_s;   "#{flag_name(@type)}(#{@id})" end
    def position; [@x, @y] end
    # Method in Map
    def moveTo(x, y)
      return putError('Unset Map.') if @map.nil?
      @map.move(@x, @y, x, y)
      self
    end
    def moveIn(dir)
      x, y = dir_move(dir,@x,@y)
      moveTo(x, y)
    end
    def removeMap
      @map.clear(@x,@y)
      @x = @y = 0
      @map = nil
      self
    end
  end

  #-------------------------------------------------
  # Class SetterMap
  #-------------------------------------------------
  class SetterMap < Map
    # Reader
    attr_reader :chrecord # Change Count Record
    # Initialize
    def initialize(x, y)
      super(x,y)
      set_with_index { |tx,ty| init(tx,ty) }
      @chrecord = 0
    end
    # Method
    def []=(x, y, setter)
      return putError('Not Setter.') unless setter.is_a?(Setter)
      if (!setter.map.nil?)
        if (setter.map == self)
          putWarning('Move a Setted Setter.')
        else
          putError('Move a Setter in Other Map.')
        end
        clear(setter.x,setter.y)
      end
      setSetter(setter,x,y)
      set(x,y,setter)
    end
    def move(fx, fy, tx, ty)
      return if (judgeError(fx,fy) || judgeError(tx,ty))
      return putWarning("Move Self to Self(#{tx}, #{ty}).") if ((fx == tx) && (fy == ty))
      return putError("There is Not Blank.") if (!get(tx,ty).blank?)
      swap(fx, fy, tx, ty)
      get(tx,ty).setPost(tx,ty)
      get(fx,fy).setPost(fx,fy)
      changeRecord
      self
    end
    def clear(x, y)
      set(x,y,init(x,y))
    end
    # Create Map Method
    def create_typemap
      new { |e| e.type }
    end
    def changeRecord
      @chrecord += 1
    end

  private
    def setSetter(setter, x, y)
      setter.setPost(x,y).setMap(self)
    end
    def init(x, y)
      setSetter(Setter.new, x, y)
    end
  end

  #-------------------------------------------------
  # Class SetterData
  #-------------------------------------------------
  class SetterData
    include DataPush
    include Enumerable
    def initialize(data = nil)
      @data = Hash.new
      @type = nil
      init_data(data)
    end
    # We could only push one type of setter.
    def push_basic(setter)
      putError("Setter ID is Repeated.") if (!@data[setter.id].nil?)
      putError("Type is Not Same.") if (!@type.nil? && (setter.type != @type))
      @data[setter.id] = setter
      @type ||= setter.type
      self
    end
    def clear
      @data.delete_if { |k, e| e.type != @type  }
    end
    def empty?
      @data.empty?
    end
    def first
      @data.first[1]
    end
    def data
      @data.values
    end
    def delete(id)
      # TODO : Will Be Deleted
      putError("Not Found Setter ID(#{id}).") if (@data[id].nil?)
      @data.delete(id)
    end
    def each
      @data.each_value { |i| yield(i) }
    end
    def to_list
      SetterList.new.push(*@data.values)
    end
    def to_s
      "<DATA>" << Output.array_to_s(@data.values)
    end
  end

  #-------------------------------------------------
  # Class SetterDatas
  #-------------------------------------------------
  class SetterDatas
    include DataPush
    include Enumerable
    def initialize(data = nil)
      @data = Hash.new
      init_data(data)
    end
    def push_basic(setter)
      return putError("Setter Pushed is Wrong.") if (setter.class != Setter)
      type = setter.type
      @data[type] ||= SetterData.new
      @data[type].push_basic(setter)
    end
    def [](type)
      @data[type] ||= SetterData.new
    end
    def each(&block)
      each_with(*@data.keys,&block)
    end
    def each_with(*args)
      args.each { |type| self[type].each { |data| yield(data,type) } }
    end
    def to_s
      "<DATAS>{" << Output.list_to_s(@data.values) << "}"
    end
  end

  #-------------------------------------------------
  # Class SetterList
  #-------------------------------------------------
  class SetterList
    include DataPush
    def initialize(data = nil)
      @data = Array.new
      init_data(data)
    end
    def push_basic(setter)
      return putError("Setter Pushed is Wrong.") if (setter.class != Setter)
      @data.push(setter)
      self
    end
    def first
      @data.first
    end
    def next(del = false)
      @data.push(@data.first) unless (del)
      @data.shift
      self
    end
    def delete(id, type = nil)
      if (type.nil?)
        @data.delete_at(id-1)
      else
        @data.each_with_index { |e,i| @data.delete_at(i) if ((e.type == type) && (e.id == id)) }
      end
    end
    def empty?
      @data.empty?
    end
    def each(*args, &block)
      @data.each(*args,&block)
    end
    def to_s
      "<LIST>" << Output.array_to_s(@data)
    end
  end
end

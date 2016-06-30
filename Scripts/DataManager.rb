#=================================================
# SRPG::DataManager
#-------------------------------------------------
# Update : 06/27/2016
#=================================================

module SRPG
  module DataManager
    # + Initialize
    #  Use it when start game.
    #  input : DataLists
    def self.init(datalists)
      @database = datalists
    end
    # + Get
    def self.get(key, id = nil)
      @database.get(key,id)
    end
    def self.get_data(key)
      @database.get_data(key)
    end
  end
  module DataManager
    # + Struct
    class DataList < Struct.new(:class, :data)
      include Enumerable
      def get(id)
        new(self.data[id])
      end
      def each
        self.data.each { |ele| yield(new(ele)) }
      end
      def check_collect
        collect { |dat| dat.have_nil? ? nil : yield(dat) }
      end

      private
      def new(ele)
        self.class.new(ele)
      end
      def []; end
    end
    class FuncCall
      include Reference
      def data
        @data.call
      end
    end
    class DataLists < Hash
      # + Add
      def add(key, type, value)
        self[key] = DataList.new(type, value)
      end
      def add_func(key, func)
        self[key] = FuncCall.new(func)
      end
      # + Get
      def get(key, id = nil)
        id.nil? ? self[key] : self[key].get(id)
      end
      def get_data(key)
        self[key].data
      end
    end
  end
end

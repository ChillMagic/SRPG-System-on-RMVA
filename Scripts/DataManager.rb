#=================================================
# SRPG::DataManager
#-------------------------------------------------
# Update : 06/27/2016
#=================================================

module SRPG
  module DataManager
    # + Struct
    class DataList < Struct.new(:class, :data)
      def get(id)
        self.class.new(self.data[id])
      end
    end
    class DataLists < Hash
      def add(key, type, value)
        self[key]  = DataList.new(type, value)
      end
    end
    # + Initialize
    #  Use it when start game.
    # input : { key: data, ... }
    def self.init(dataLists)
      @@database = dataLists
    end
    # + Get
    def self.get(key, id = nil)
      id.nil? ? get_list(key).data : get_data(key, id)
    end
    # + Get List
    #  output : DataList
    def self.get_list(key)
      @@database[key]
    end
    # + Get List Type
    #  output : class<T>
    def self.get_list_class(key)
      @@database[key].class
    end
    # + Get Data
    #  output : T
    def self.get_data(key, id)
      @@database[key].get(id)
    end
  end
end

#=================================================
# SRPG::Record
#-------------------------------------------------
# Update : 04/03/2016
#=================================================

module SRPG
  module Record
    private
    # Record
    def init_record
      @record ||= Hash.new
    end
    def set_record(key, value)
      init_record
      puts("Set Record(#{key}).") if (Record.print_log?)
      @record[key] = value
    end
    def first_set_record(key, value)
      init_record
      if (@record[key].nil?)
        puts("Set Record(#{key}).") if (Record.print_log?)
        @record[key] = value
      end
      return @record[key]
    end
    def change_record(key, value)
      init_record
      @record[key] = value
    end
    def get_record(key, check = true)
      init_record
      return putError("The Record(#{key}) is not defined.") if (check && !@record.has_key?(key))
      @record[key]
    end
    def del_record(*keys)
      init_record
      keys.flatten.each do |key|
        puts("Delete Record(#{key}).") if (Record.print_log?)
        @record.delete(key)
      end
    end
    def clean_record
      @record = Hash.new
    end
    # Log
    def self.print_log?
      @print_log
    end
    def self.print_log=(switch)
      @print_log = switch
    end
    # Debug
    def none_repeat_do(meth, *args)
      result = nil
      if (first_set_record(__method__, args))
        result = meth.call(*args)
      elsif (get_record(__method__) != args)
        result = meth.call(*args)
        set_record(__method__, args)
      end
      return result
    end
    def none_repeat_p(inc)
      none_repeat_do(method(:p),inc)
    end
  end
  class RecordObject
    include Record
    def initialize
      init_record
    end
    def first_set(*args)
      first_set_record(*args)
    end
    def set(*args)
      set_record(*args)
    end
    def get(*args)
      get_record(*args)
    end
    def change(*args)
      change_record(*args)
    end
    def delete(*args)
      del_record(*args)
    end
    def clear
      clean_record
    end
  end
end

#=================================================
# System
#-------------------------------------------------
# Update : 12/17/2015
#=================================================

module Chill
  # Method
  def max(a,b); return (a>b) ? a : b; end
  def min(a,b); return (a<b) ? a : b; end
  #def putError(msg); puts(msg); exit; end
  # Self Method
  def self.test
    t = Time.new
    yield
    Time.new - t
  end
end

module Chill
  CHECK_FUNCTION = true

  if CHECK_FUNCTION
    def self.checkType(types, args)
      if (types.length != args.length)
        putTypeErrorMessage(type, value)
      end
      types.each_index do |i|
        type = types[i]
        value = args[i]
        unless checkTypeBase(type, value)
          putTypeErrorMessage(type, value, i+1)
        end
      end
    end
    def self.checkSingleType(type, arg)
      unless checkTypeBase(type, arg)
        putTypeErrorMessage(type, arg)
      end
    end
    def self.checkSingleTypes(type, args)
      args.each do |value|
        unless checkTypeBase(type, value)
          putTypeErrorMessage(type, value)
        end
      end
    end
    def self.putTypeErrorMessage(type, value, parcount = nil)
      puts("Error type" + (parcount ? " for par(#{parcount})" : "") +
               ", #{value.class} => #{type}.")
      raise
    end
    def self.checkTypeBase(type, value)
      return type.is_a?(Class) ? value.is_a?(type) : type.any? { |t| value.is_a?(t) }
    end
  else
    def self.checkType(*args)
    end
    def self.checkSingleType(*args)
    end
    def self.checkSingleTypes(*args)
    end
  end
end

BEGIN {
  class ErrorInfo
    WriteErrInfo = false
    attr_accessor :errinfo, :errexit
    def initialize
      if WriteErrInfo
        filename = "./errinfo.txt"
        File.new(filename, "w").close
        @errinfo = File.new(filename, "a")
      end
      @errexit = true
    end
    def putError(msg, cod = nil)
      putInfoJudge(msg,:error,cod)
    end
    def putWarning(msg, cod = nil)
      putInfoJudge(msg,:warning,cod)
    end

    def exit
      @errinfo.close if WriteErrInfo
    end

    private
    def getInfo(msg, type)
      case type
      when :error
        "#ERROR:\n>  " + msg + "\n"
      when :warning
        @errcount ||= 0
        "#WARNING(#{@errcount+=1}):\n>  " + msg + "\n"
      else
        ""
      end
    end
    def putInfo(msg, type)
      msg = getInfo(msg,type)
      puts(msg)
      @errinfo.puts(msg) if WriteErrInfo
      exit if (@errexit && (type == :error))
    end
    def putInfoJudge(msg, type, cod = nil)
      putInfo(msg,type) if (cod.nil? || cod)
      cod
    end
  end
  $errinfo = ErrorInfo.new
}

END {
  $errinfo.exit
}

def putWarning(*args)
  $errinfo.putWarning(*args)
end

def putError(*args)
  if $errinfo.errexit
    $errinfo.putError(*args)
  else
    putWarning(*args)
  end
end


class Object
  alias this class
end

class String
  def humanize
    self[0].upcase + self[1,size-1]
  end
end
class Module
  def get_constexpr(symbol)
    module_eval(symbol.to_s.humanize)
  end
  def attr_reference(*symbols)
    symbols.each { |sym| module_eval("def #{sym}; @data.#{sym}; end") }
  end
  def attr_referenceset(*symbols)
    symbols.each { |sym| module_eval("def #{sym}=(e); @data.#{sym}=(e); end") }
  end
  def attr_referenceref(*symbols)
    symbols.each { |sym| module_eval("def #{sym}; @data.#{sym}; end; def #{sym}=(e); @data.#{sym}=(e); end") }
  end
  def attr_referencefun(*symbols)
    symbols.each { |sym| module_eval("def #{sym}(*args); @data.#{sym}(*args); end") }
  end
end
class Struct
  def assign_with_struct(struct)
    self.members.each { |sym| eval("self.#{sym} = struct.#{sym}") }
    return self
  end
end
module Reference
  def initialize(data)
    @data = data
  end
end
class ReferClass
  include Reference
end
module SRPG end

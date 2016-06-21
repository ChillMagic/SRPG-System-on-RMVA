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
end

module SRPG end
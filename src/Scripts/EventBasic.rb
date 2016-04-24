#=================================================
# SRPG::EventBasic
#-------------------------------------------------
# Update : 03/20/2016
#=================================================

module SRPG
  module EventBasic
    # Const
    DoFlag   = Struct.new(:flag,:record)
    RankData = Struct.new(:start,:update,:over)
    # Initialize
    def initialize(event_key)
      # State
      @doflag = Array.new  # Stack
      @docomd = Array.new  # Queue
      # Event Key
      set_eventkey(event_key)
    end
    #------------------------------
    # State Control
    #------------------------------
    # Usage :
    # example:
    #   event.move(...)
    #   return if (event.doing?)
    #------------------------------
    def doing?(flag = nil)
      update
      return false if @doflag.empty?
      flag.nil? ? true : (doing.flag == flag)
    end
    def done?(flag = nil)
      !doing?(flag)
    end
    def interpreter_add(*commands)
      @docomd.push(*commands)
    end
    def interpreter_doing?
      result = !@docomd.empty?
      docond = doing?
      interpreter(@docomd.shift) if (!docond && result)
      return result || docond
    end
    private
    #------------------------------
    # State Control
    # Use 'doing?' for showing, moving... etc.
    #   For update and over in time.
    # Example :
    #    return if (doing?)
    #    if (doing?(:move))
    def setflag(flag)
      @doflag.push(DoFlag.new(flag,RecordObject.new))
    end
    def set_afterdo(flag,*args)
      rec = @doflag.pop
      send(flag,*args)
      @doflag.push(rec)
    end
    def update
      return if (@doflag.empty?)
      method(eventkey[doing.flag].update).call
    end
    def over
      return if (@doflag.empty?)
      return putError("Unfind flag(#{@doneflag.last}).") unless eventkey[@doflag.last.flag]
      method(eventkey[doing.flag].over).call
      done
      interpreter(@docomd.shift) if (!@docomd.empty?)
    end
    def done
      @doflag.pop
    end
    def doing
      @doflag.last
    end
    def doflag
      @doflag.collect { |e| e.flag }
    end
    def blank
    end
    def blank_check
      putError("Call blank method.")
    end
    def interpreter(commands)
      command, args = commands
      return args ? method(command).call(*args) : method(command).call
    end
    #------------------------------
    # Event Key
    def set_eventkey(inc)
      @eventkey = inc
    end
    def eventkey
      @eventkey
    end
    #------------------------------
    # Record
    def set_record(*args)
      return putError("#{__method__}(#{args})") if doing.nil?
      doing.record.set(*args)
    end
    def get_record(*args)
      return putError("#{__method__}(#{args})") if doing.nil?
      doing.record.get(*args)
    end
    def change_record(*args)
      set_record(*args)
    end
    def del_record(*args)
      putError("#{__method__}(#{args})")
    end
  end
end

#=================================================
# SRPG::Debugger
#-------------------------------------------------
# Update : 12/01/2015
#=================================================

module SRPG
  class Debugger
    # Initialize
    def initialize(bind, map)
      puts("-------------------------------")
      puts("> SMSK Kernel Debugger (SKD)")
      puts("-------------------------------")
      puts("> Loading...")
      printOn
      @binding = bind ? bind : run
      @map = map
    end
    # Run
    def run
      binding
    end
    # Start
    def start
      puts("> Launched.")
      #print(": ")
      $errinfo.errexit = false
      while (str = gets)
        @flag = false
        str += gets while (str[-2] == ";")
        begin
          if (i = (str =~ /<</))
            n = inter(str,i)
          elsif (str[0] == '!')
            n = eval(str[1,str.size])
          else
            n = eval(str,@binding)
          end
          print('>>', ((n.nil?) ? 'nil' : n), "\n") if @isPrint
        rescue SyntaxError => res
          putError('syntax error')
        rescue SystemStackError => res
          putError(res.to_s)
        rescue => res
          putError(res.to_s)
        rescue Interrupt => res #Exception => res
          putError(Interrupt.to_s)
        end
        break if @flag
        #print(": ")
      end
      $errinfo.errexit = true
    end
    def exit
      @flag = true
    end

private
    # Private Method
    alias pr print
    def printMap
      cx, cy = @map.x, @map.y
      pl = ->(char1, char2, char3) do
        pr(char1)
        cx.times do |x|
          pr('───────')
          break if (x == cx-1)
          pr(char2)
        end
        pr(char3)
        pr("\n")
      end
      ps = ->(&block) do
        cx.times do |x|
          pr('│ ')
          pr(block.call(x))
          pr(' ')
        end
        pr("│\n")
      end
      pl.call('┌','┬','┐')
      cy.times do |y|
        ps.call { |x| @map[x,y] }
        break if (y == cy-1)
        pl.call('├','┼','┤')
      end
      pl.call('└','┴','┘')
    end
    def printOn
      @isPrint = true
    end
    def printOff
      @isPrint = false
    end
    def inter(string, i)
      s1 = string[0...i]
      s2 = string[(i+2)...string.size]
      eval("(#{s1}).#{s2}",@binding)
    end
  end
end

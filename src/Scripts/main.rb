#!usr/bin/ruby
alias import require_relative
import 'System'
import 'Basic'
import 'Map'
import 'Range'
import 'Setter'
import 'Data'
import 'Action'
import 'AI'
import 'Battle'
import 'Battler'
import 'BaseItem'
import 'Record'
import 'Debugger'
import 'SpriteBasic'
import 'EventBasic'
include Chill

# Compatible
$global = binding
def compatible
  eval(%{
  }, $global)
end

module SRPG
  class Debugger
    def run
      # Return
      binding
    end
  end
end

puts("====================================")
puts("* SRPG on Map System Kernel (SMSK)")
puts("* By Chill")
puts("* Version 1.0.0.0")
puts("====================================")

SRPG_KERNEL_LOADED = true

Chill.test {}

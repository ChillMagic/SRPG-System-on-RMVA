#!usr/bin/ruby
alias import require_relative
import 'System'
import 'Basic'
import 'Map'
import 'Data'
import 'Range'
import 'Setter'
import 'ActionStatus'
import 'AI'
import 'BaseData'
import 'Battle'
import 'Battler'
import 'BattleDamage'
import 'DataManager'
import 'Record'
import 'Debugger'
import 'SpriteBasic'
import 'EventBasic'
import 'ActionBasic'
include Chill

# Compatible
$global = binding
def compatible
  eval(%{
  }, $global)
end

# class A
#   def method_missing(func, *args, &block)
#     p func
#     p args
#   end
# end
# a = A.new
# a.f(:chill)
# :f
# [:chil]

module SRPG
  class Debugger
    def run
      # Return
      binding
    end
  end
end

SRPG_KERNEL_VERSION = '0.9.0.2'
SRPG_KERNEL_LOADED  = true

puts("====================================")
puts("* SRPG on Map System Kernel (SMSK)")
puts("* By Chill")
puts("* Version #{SRPG_KERNEL_VERSION}")
puts("====================================")

Chill.test {}

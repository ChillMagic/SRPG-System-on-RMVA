alias old_import import
def import(arg)
  old_import('BattleEvent/'+arg)
end

import '1.Command'
import '2.Event'
import '3.Calc'
import '4.BattleEvent'
import '5.Data'
import '6.Menu'

alias import old_import
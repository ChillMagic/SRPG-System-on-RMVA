# Main Interface

alias import require_relative
require_relative '../System'
require_relative '../Map'
require_relative '../Data'
require_relative 'Data/Battler'
require_relative 'Battler'
require_relative 'Troop'
require_relative 'RGSSToData'

PropertyToKernel = {
  mhp: :mhp,
  pow: :pat,
  def: :pdf,
  mag: :mat,
  mdf: :mdf,
  tec: :mmp,
  agi: :agi,
  luk: :luk,
  mov: :move,
  viw: :view
}

def __main__
  DataManager.init

  src = $game_actors[1]
  note = $data_actors[src.id].note
  notdat = SRPG::RGSSToData.loadFromNote(note)
  battler = SRPG::RGSSToData.loadActorToBattler(src)
  
  notdat.each do |prop, value|
    begin
      battler.send(PropertyToKernel[prop].to_s+'=', value)
    rescue => res
      putError(res.to_s)
    end
  end

  p battler

  system("pause")
  exit(0)
end

__main__

SRPG_KERNEL_VERSION = 0.1
SRPG_KERNEL_LOADED  = true

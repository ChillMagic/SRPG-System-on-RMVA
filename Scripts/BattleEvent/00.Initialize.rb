
# Initialze

module SRPG
  module Data
    def self.init
      # Init DataManager
      dls = DataManager::DataLists.new
      dls.add(:actor,  Actor,  $data_actors)
      dls.add(:enemy,  Enemy,  $data_enemies)
      dls.add(:class,  Class,  $data_classes)
      dls.add(:skill,  Skill,  $data_skills)
      dls.add(:item,   Item,   $data_items)
      dls.add(:weapon, Weapon, $data_weapons)
      dls.add(:armor,  Armor,  $data_armors)
      dls.add(:state,  State,  $data_states)
      dls.add_func(:variables, lambda{$game_variables})
      DataManager.init(dls)
    end
  end
end


# Compatible
$global = binding
def compatible_
  eval(%{
class << SRPG::Battle
  def print_gotolog?;        false;                 end
end
class Spriteset_Range
  Blue    = 0  # 蓝色
  Orange  = 1  # 橙色
  Red     = 2  # 红色
  Celeste = 3  # 青色
  Green   = 4  # 绿色
  Gray    = 5  # 灰色
end
       }, $global)
end

compatible_
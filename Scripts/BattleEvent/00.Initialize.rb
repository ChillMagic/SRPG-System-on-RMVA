
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

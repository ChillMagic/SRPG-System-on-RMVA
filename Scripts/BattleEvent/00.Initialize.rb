# Initialze

module SRPG
  module Data
    def self.init
      init_data
      init_battledamge
    end
    # Init DataManager
    def self.init_data
      dls = DataManager::DataLists.new
      dls.add(:actor,  Actor,  $data_actors)
      dls.add(:enemy,  Enemy,  $data_enemies)
      dls.add(:class,  Class,  $data_classes)
      dls.add(:skill,  Skill,  $data_skills)
      dls.add(:item,   Item,   $data_items)
      dls.add(:weapon, Weapon, $data_weapons)
      dls.add(:armor,  Armor,  $data_armors)
      dls.add(:state,  State,  $data_states)
      DataManager.init(dls)
    end
    # Init BattleDamage
    def self.init_battledamge
      BattleDamage.set_variables($game_variables)
      BattleDamage.set_damagelist(Hash.new)
      damagelist = BattleDamage.get_damagelist
      damagelist[:item]  = DataManager.get(:item).collect  { |dat| Damage.new(dat.damage) unless dat.nil? }
      damagelist[:skill] = DataManager.get(:skill).collect { |dat| Damage.new(dat.damage) unless dat.nil? }
      BattleDamage.set_damagelist(damagelist)
    end
  end
end

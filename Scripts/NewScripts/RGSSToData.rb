
# 从 RGSS 加载数据到 SRPG::Data 中

module SRPG
  module RGSSToData
    # 对应关系

    # Game_Actor  $game_actors   Data::Battler
    # Game_Enemy  Game_Enemy.new Data::Battler
    # Weapon $data_weapons Data::Equip
    # Armor  $data_armors  Data::Equip
    # Class  $data_classes Data::Occupation (待定)
    # Skill  $data_skills  Data::Skill (待定)
    # Item   $data_items   Data::Item (待定)
    # State  $data_states  Data::State (待定)

    def self.loadActorToBattler(src)
      Chill.checkSingleType(Game_Actor, src)
      return loadBattlerCommon(src)
    end
    def self.loadEnemyToBattler(src)
      Chill.checkSingleType(Game_Enemy, src)
      return loadBattlerCommon(src)
    end

    def self.loadWeaponToEquip(src)
      Chill.checkSingleType(RPG::Weapon, src)
      return 
    end
    def self.loadArmorToEquip(src)
      Chill.checkSingleType(RPG::Armor, src)
      return 
    end


    RGSS_Param = { mhp: 0, mmp: 1, atk: 2, def: 3, mat: 4, mdf: 5, agi: 6, luk: 7 }

    def self.getRGSSParam(params, prop)
      return params[RGSS_Param[prop]]
    end

    def self.loadBattlerCommon(src)
      # Create
      dst = Data::Battler.new
      # Load Basic Parameter
      dst.mhp = src.mhp
      dst.mmp = src.mmp
      dst.pat = src.atk
      dst.pdf = src.def
      dst.mat = src.mat
      dst.mdf = src.mdf
      dst.agi = src.agi
      dst.luk = src.luk
      # Load Map Parameter
      dst.move = src.move
      dst.view = src.view
      # Return
      return dst
    end

    def self.loadEquipCommon(src)
      # Create
      dst = Data::Equip.new
      params = src.params
      # Load Basic Parameter
      dst.mhp = getRGSSParam(params, :mhp)
      dst.mmp = getRGSSParam(params, :mmp)
      dst.pat = getRGSSParam(params, :atk)
      dst.pdf = getRGSSParam(params, :def)
      dst.mat = getRGSSParam(params, :mat)
      dst.mdf = getRGSSParam(params, :mdf)
      dst.agi = getRGSSParam(params, :agi)
      dst.luk = getRGSSParam(params, :luk)
    end
    
    # Note 的书写规则：
    #   一行内： 属性名称 + ':' + 值 。
    #   多行： 带有 MAP 字样的，将从行末的 '(' 直到到 ')' 作为 MatchMap 解析。
    #   区分大小写，属性名称内不存在空白字符。
    #   不符合情况的，均视为说明文字，不作解析。
    def self.loadFromNote(note)
      data = Array.new
      note_data = note.lines.to_a
      i = 0
      while (i < note_data.length)
        line = note_data[i]
        index = line.index(':')
        if (index)
          prop = line[0, index - 1]
          if (prop =~ (/\A(\w+)\s*\Z/))
            prop = $1
            expr = line[index + 1, line.size - index - 1]
            begin
              value = eval(expr)
              data.push([prop.to_sym, value])
            rescue Exception
              if (expr =~ /MAP\s*\(/)
                id = expr.index('(')
                expr = expr[id, expr.size - id - 1]
                loop do
                  i = i.next
                  exp = note_data[i]
                  expr += exp
                  if (exp.include?(')'))
                    value = Data::MatchMap.matchMap(expr)
                    data.push([prop.to_sym, value])
                    break
                  end
                end
              end
            end
          end
        end
        i = i.next
      end
      return data
    end

  end
end

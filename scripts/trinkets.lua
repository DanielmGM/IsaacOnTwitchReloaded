local trinkets = {}

-- Example
--trinkets.ItemName= {
--  id = Isaac.GetItemIdByName("Item Name"), <-- Item Id
--  name = "Item name", <-- Item name, required for dynamic item loading on site
--  description = {en = "Item description", ru = "Описание" }, <-- Item description for external item description mod
--  hold = flase, <-- If player hold trinket now
--  onPickup = nil, <-- Function, called on pickup item
--  onUpdate = nil, <-- Function, called every update when player have item
--  onCacheUpdate = nil, <-- Function, called when player stats evaluate
--  onEntityUpdate = nil, <-- Functon, called for every enemy on postUpdate
--  onRoomChange = nil, <-- Function, called when room changed
--  onDamage = nil, <-- Function, called when player get damage
--  onNPCDeath = nil, <-- Function, called when NPC died
--  onTearUpdate = nil, <-- Function, called when tier updated
--  onProjectileUpdate = nil, <-- Function, called when projectile updated
--  onStageChange = nil, <-- Function, called when stage changed
--  onRemove = nil <-- Function, called when item removed

--}

-- Neo glasses for Neonomi
trinkets.T_NeoGlasses = {
  id = Isaac.GetTrinketIdByName("Neo glasses"),
  name = "Neo glasses",
  
  description = {
    en = "\1 Enemy projectiles can turn around",
    ru = "\1 Вражеские выстрелы могут развернуться",
    es = "\1 Los proyectiles enemigos pueden girar"
  },
  
  hold = false,
  
  onEntityUpdate = function (entity)
    if (entity.Type == EntityType.ENTITY_PROJECTILE and entity.FrameCount > 10 and math.random(1,100) <= 2) then
      Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, entity.Position, entity.Velocity*-1, Isaac.GetPlayer(0))
      entity:Die()
    end
  end
  
}

-- Hair clap for Hutts
trinkets.T_HairClap = {
  id = Isaac.GetTrinketIdByName("Hair clap"),
  name = "Hair clap",
  
  description = {
    en = "\1 Can spawn 1-3 friendly corn mine in new rooms",
    ru = "\1 Может призвать 1-3 дружеских мин в новых комнатах",
    es = "\1 Puede crear 1-3 minas de maíz amigables en nuevas habitaciones"
  },
  
  hold = false,
  
  onNewRoom = function ()
    if (math.random(1,100) > 15) then return end
    local room = Game():GetRoom()
    for i = 1, math.random(1,3) do
      local enemy = Isaac.Spawn(EntityType.ENTITY_CORN_MINE, 0,  0, room:GetRandomPosition(1), Vector.Zero, Isaac.GetPlayer(0))
      enemy:AddCharmed(EntityRef(Isaac.GetPlayer()), -1)
      enemy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
    end
  end
  
}

-- Torn cat ear for Tijoe
trinkets.T_TornFoxEar = {
  id = Isaac.GetTrinketIdByName("Torn fox ear"),
  name = "Torn fox ear",
  
  description = {
    en = "\1 You can fire tear with x30 damage#After firing, you can get damage with 30% chance",
    ru = "\1 Вы можете выстрелить слезой с х30 уроном#После выстрела, вы можете получить урон с шансом 30%",
    es = "\1 Puede disparar una lágrima de daño x30#Después de disparar, puedes recibir daño con un 30% de probabilidad"

  },
  
  hold = false,
  
  onUpdate = function ()
    local p = Isaac.GetPlayer(0)
    
    if (math.random(1, 1000) > 996) and (p:GetFireDirection() ~= Direction.NO_DIRECTION) then
      local t = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, p.Position, Vector(p:GetShootingInput().X*15, p:GetShootingInput().Y*15), p):ToTear()
      t.CollisionDamage = p.Damage * 5
      t:ChangeVariant(TearVariant.MULTIDIMENSIONAL)
      t.TearFlags = IOTR._.setbit(t.TearFlags, TearFlags.TEAR_SPECTRAL)
      t.TearFlags = IOTR._.setbit(t.TearFlags, TearFlags.TEAR_PIERCING)
      t.TearFlags = IOTR._.setbit(t.TearFlags, TearFlags.TEAR_HOMING)
      t:SetColor(IOTR.Enums.Rainbow[1], 0, 0, false, false)
      t.Scale = 5
      
      if (math.random(1,10) <= 3) then
        p:TakeDamage (0.5, DamageFlag.DAMAGE_FIRE, EntityRef(p), 30)
      end
    end
    
  end
  
}

-- Gribulya's piece for Rekvi
trinkets.T_GribulyasPiece = {
  id = Isaac.GetTrinketIdByName("Gribulya's piece"),
  name = "Gribulya's piece",
  
  description = {
    en = "\1 Can spawn 1-3 friendly mushrooms",
    ru = "\1 может призвать 1-3 дружелюбных гриба",
    es = "\1 Puede crear 1-3 hongos amigables"
  },
  
  hold = false,
  
  onRoomChange = function ()
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    
    local e = Isaac.FindByType(EntityType.ENTITY_MUSHROOM, 0,  500, true, false)
    for _, entity in pairs(e) do
      entity:Remove()
    end
    
    if (math.random(1,5) == 1) then
      for i = 1, math.random(1,3) do
        local unit = Isaac.Spawn(EntityType.ENTITY_MUSHROOM, 0,  500, room:GetRandomPosition(4), Vector.Zero, player)
        unit:AddCharmed(EntityRef(player), -1)
        unit:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        unit:SetColor(IOTR.Enums.Rainbow[math.random(#IOTR.Enums.Rainbow)], 0, 0, false, false)
      end
    end
    
  end
  
}

-- Spacesuit charge indicator for iVertox
trinkets.T_SpacesuitChargeIndicator = {
  id = Isaac.GetTrinketIdByName("Spacesuit charge indicator"),
  name = "Spacesuit charge indicator",
  
  description = {
    en = "\1 Can spawn friendly dark shadow#Give speed boost with curse of dark",
    ru = "\1 Спавнит дружелюбную черную тень#Увеличивает скорость при проклятии темноты",
    es = "\1 Puede crear una sombra amigable#Aumenta la velocidad con la maldición de la oscuridad"
  },
  
  hold = false,
  
  onNewRoom = function ()
    if (math.random(1,100) > 15) then return end
    
    local room = Game():GetRoom()
    local player = Isaac.GetPlayer(0)
    local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 20, true)
    local unit = Isaac.Spawn(EntityType.ENTITY_HUSH_GAPER, 0,  0, pos, Vector.Zero, player)
    unit:ToNPC().MaxHitPoints = player.Damage * 5
    unit:ToNPC().HitPoints = player.Damage * 5
    unit:SetColor(Color(0,0,0,0.4,1,1,1), 0, 0, false, false)
    unit:AddCharmed(EntityRef(player), -1)
    unit:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
  end,
  
  onStageChange = function ()
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_SPEED)
    Isaac.GetPlayer(0):EvaluateItems()
  end,
  
  onCacheUpdate = function (player, cacheFlag)
    if (IOTR._.hasbit(Game():GetLevel():GetCurses(), LevelCurse.CURSE_OF_DARKNESS)) then
      if (IOTR._.hasbit(cacheFlag, CacheFlag.CACHE_SPEED)) then
        player.MoveSpeed = player.MoveSpeed + .2
      end
    end
  end,
  
  onRemove = function ()
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_SPEED)
    Isaac.GetPlayer(0):EvaluateItems()
  end,
  
  onPickup = function ()
    Isaac.GetPlayer(0):AddCacheFlags(CacheFlag.CACHE_SPEED)
    Isaac.GetPlayer(0):EvaluateItems()
  end
  
}

-- Coin eye for MrOst Sergey
trinkets.T_GreedCoinEye = {
  id = Isaac.GetTrinketIdByName("Greed coin eye"),
  name = "Greed coin eye",
  
  description = {
    en = "\1 Can fire coin tear with Midas effect",
    ru = "\1 Возможен выстрел слезой-монетой с эффектом Мидаса",
    es = "\1 Puedes disparar una lágrima de moneda con el efecto de Midas"
  },
  
  hold = false,
  
  onTearUpdate = function (tear)
    if (tear.FrameCount == 1 and math.random(1,13) == 1) then
      tear:ChangeVariant(TearVariant.COIN)
      tear.TearFlags = IOTR._.setbit(tear.TearFlags, TearFlags.TEAR_COIN_DROP)
      tear.TearFlags = IOTR._.setbit(tear.TearFlags, TearFlags.TEAR_MIDAS)
    end
    
  end
  
}

-- Crystal shard for Crystal
trinkets.T_CrystalShard = {
  id = Isaac.GetTrinketIdByName("Crystal shard"),
  name = "Crystal shard",
  
  description = {
    en = "\1 Can spawn tears in circle shape around player on damage",
    ru = "\1 Может создать круг из слез вокруг игрока при получении урона",
    es = "\1 Puede crear lágrimas en forma de círculo alrededor al recibir daño"
  },
  
  hold = false,
  
  onDamage = function (entity, damageAmnt, damageFlag, damageSource, damageCountdown)
    if (entity.Type ~= EntityType.ENTITY_PLAYER) or math.random(5) ~= 5 then return end
      
    local p = entity:ToPlayer()
    local tears = {}
    
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(50,-30), Vector(5,-3), p))
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(0,-50), Vector(0,-5), p))
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(-50,-30), Vector(-5,-3), p))
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(-50,30), Vector(-5,3), p))
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(0,50), Vector(0,5), p))
    table.insert(tears, Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.DIAMOND, 0, p.Position + Vector(50,30), Vector(5,3), p))
    
    
    for _, t in ipairs(tears) do
      t:ToTear().TearFlags = IOTR._.setbit(t:ToTear().TearFlags, TearFlags.TEAR_LASER)
      t:ToTear().TearFlags = IOTR._.setbit(t:ToTear().TearFlags, TearFlags.TEAR_WAIT)
      t:ToTear().TearFlags = IOTR._.setbit(t:ToTear().TearFlags, TearFlags.TEAR_QUADSPLIT)
      t:ToTear().TearFlags = IOTR._.setbit(t:ToTear().TearFlags, TearFlags.TEAR_PIERCING)
      t:ToTear().TearFlags = IOTR._.setbit(t:ToTear().TearFlags, TearFlags.TEAR_SPECTRAL)
      t.CollisionDamage = p.Damage
    end
    
  end
  
}

-- Grizzly claw for GrizzlyGuy
trinkets.T_GrizzlyClaw = {
  id = Isaac.GetTrinketIdByName("Grizzly claw"),
  name = "Grizzly claw",
  
  description = {
    en = "\1 Can spawn shockwave and fear enemies around player on damage",
    ru = "\1 Может создать каменную волну и напугать врагов вокруг при получении урона",
    es = "\1 Puede crear una onda de choque y atemorizar a los enemigos alrededor del jugador al recibir daño"
  },
  
  hold = false,
  
  onDamage = function (entity, damageAmnt, damageFlag, damageSource, damageCountdown)
    if (entity.Type ~= EntityType.ENTITY_PLAYER) or math.random(5) ~= 5 then return end
      
    local p = entity:ToPlayer()
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, p.Position, Vector.Zero, p)
    
    for k, v in pairs(Isaac.GetRoomEntities()) do
      if (v:IsActiveEnemy(false) and v:IsVulnerableEnemy() and (p.Position:Distance(v.Position) <= 200)) then
        v:AddFear (EntityRef(p), 300)
      end
    end
    
    
  end
  
}

-- Inverted Cross for HellYeahPlay
trinkets.T_InvertedCross = {
  id = Isaac.GetTrinketIdByName("Inverted Cross"),
  name = "Inverted Cross",
  
  description = {
    en = "\1 Can spawn inverted cross made from fire on damage",
    ru = "\1 Может создать перевернутый крест из огня при получении урона",
    es = "\1 Puede crear una cruz invertida hecha de fuego al recibir daño"
  },
  
  hold = false,
  
  onDamage = function (entity, damageAmnt, damageFlag, damageSource, damageCountdown)
    if (entity.Type ~= EntityType.ENTITY_PLAYER) or math.random(5) ~= 5 then return end
    
    local p = entity:ToPlayer()
    local flames = {}
    
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, p.Position, Vector.Zero, p))
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, Vector(p.Position.X-50, p.Position.Y), Vector.Zero, p))
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, Vector(p.Position.X+50, p.Position.Y), Vector.Zero, p))
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, Vector(p.Position.X, p.Position.Y-50), Vector.Zero, p))
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, Vector(p.Position.X, p.Position.Y+50), Vector.Zero, p))
    table.insert(flames, Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, Vector(p.Position.X, p.Position.Y-100), Vector.Zero, p))
    
    for i, flame in ipairs(flames) do
      
      if (i == 1) then
        flame:SetColor(Color(1, 0, 0, 1, 1.17647, 0.23529, 0.23529), 0, 0, false, false)
      else
        flame:SetColor(Color(1, 0, 0, 1, 1.17647, 0.78431, 0.78431), 0, 0, false, false)
      end
      
      flame.CollisionDamage = p.Damage
      
    end
    
    Game():Darken(0.7, 10)
    
    
  end
  
}

-- UC's stem for VitecPlay
trinkets.T_UCsStem = {
  id = Isaac.GetTrinketIdByName("UC's stem"),
  name = "UC's stem",
  
  description = {
    en = "\1 Can spawn path from tears for all enemies in room",
    ru = "\1 Может создать путь из слез до каждого врага в комнате",
    es = "\1 Puede crear un camino de lágrimas hasta cada enemigo en la habitación"
  },
  
  hold = false,
  
  onNewRoom = function ()
    if (math.random(5) ~= 5) then return end
    local p = Isaac.GetPlayer(0)
    for k, v in pairs(Isaac.GetRoomEntities()) do
      local col = nil
      
      if (v:IsActiveEnemy(false) and v:IsVulnerableEnemy()) then
        local vec = (p.Position - v.Position):Normalized()
        for i = 1, 20 do
          
          if (math.random(1,3) == 1) then
            col = IOTR.Enums.Rainbow[1]
          else
            col = IOTR.Enums.Rainbow[4]
          end
      
          local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.CUPID_BLUE, 0, p.Position-vec*i*30, Vector.Zero, p):ToTear()
          tear:SetColor(col, 0, 0, false, false)
          tear.CollisionDamage = 1.5
          tear.TearFlags = IOTR._.setbit(tear.TearFlags, TearFlags.TEAR_WAIT)
          tear.TearFlags = IOTR._.setbit(tear.TearFlags, TearFlags.TEAR_SPECTRAL)
          tear.TearFlags = IOTR._.setbit(tear.TearFlags, TearFlags.TEAR_ATTRACTOR)
        end
      end
    end
  end
  
}

-- Spider Eye for Melharucos
trinkets.T_SpiderEye = {
  id = Isaac.GetTrinketIdByName("Spider eye"),
  name = "Spider eye",
  
  description = {
    en = "\1 Can poison enemies in new room and spawn blue spider",
    ru = "\1 Может отравить врагов в комнате и создать синего паука",
    es = "\1 Puede envenenar enemigos en la habitación y crear una araña azul"
  },
  
  hold = false,
  
  onNewRoom = function ()
    if math.random(5) ~= 5 then return end
    
    local p = Isaac.GetPlayer(0)
    
    for k, v in pairs(Isaac.GetRoomEntities()) do
      if (v:IsActiveEnemy(false) and v:IsVulnerableEnemy() and math.random(3) == 3) then
        local ref = EntityRef(p)
        v:AddPoison(ref, math.random(100,300), 0.25)
      end
    end
    
    p:AddBlueSpider(p.Position)
  end
  
}

-- Broken D4-R4 console for D4N9
trinkets.T_BrokenD4R4Console = {
  id = Isaac.GetTrinketIdByName("Broken D4-R4 console"),
  name = "Broken D4-R4 console",
  
  description = {
    en = "\1 Can spawn Static Glitch and use Dataminer on damage",
    ru = "\1 Может заспавнить статический глитч и активировать Датамайнер при получении урона",
    es = "\1 Puede crear Static Glitch y activar Dataminer al recibir daño"
  },
  
  hold = false,
  
  onDamage = function (entity, damageAmnt, damageFlag, damageSource, damageCountdown)
    if (entity.Type ~= EntityType.ENTITY_PLAYER) or math.random(5) ~= 5 then return end
    
    local p = Isaac.GetPlayer(0)
    p:UseActiveItem(CollectibleType.COLLECTIBLE_DATAMINER, false, true, false, false)
    
    local glitch = Isaac.Spawn(EntityType.ENTITY_DOGMA, 10, 0, p.Position, Vector.Zero, p)
    glitch:AddCharmed(EntityRef(p), -1)
    glitch:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
  end
  
}

-- Pug tail for 
trinkets.T_PugTail = {
  id = Isaac.GetTrinketIdByName("Pug tail"),
  name = "Pug tail",
  
  description = {
    en = "\1 Has a 33% chance to spawn an explosive barrel in a room with enemies",
    ru = "\1 С шансом 33% может заспавнить взрывную бочку в комнате с врагами",
    es = "\1 Tiene un 33% de probabilidad de crear una bodega explosiva en una habitación con enemigos"
  },
  
  hold = false,
  
  onNewRoom = function ()
    if math.random(3) ~= 1 then return end
    local room = Game():GetRoom()
    local tile = room:FindFreeTilePosition(room:GetRandomPosition(0), 0)
    
    local barrel = Isaac.Spawn(EntityType.ENTITY_MOVABLE_TNT, 0, 0, tile, Vector.Zero, nil)
    barrel:SetColor(IOTR.Enums.Rainbow[1], 0, 0, false, false)
  end
  
}

return trinkets

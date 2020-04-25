local helper = {}

-- Give item function
helper.giveItem = function (name)
  local p = Isaac.GetPlayer(0);
  local item = Isaac.GetItemIdByName(name)
  p:AddCollectible(item, 0, true);
end

-- Give trinket function
helper.giveTrinket = function (name)
  local game = Game()
  local room = game:GetRoom()
  local p = Isaac.GetPlayer(0);
  local item = Isaac.GetTrinketIdByName(name)
  p:DropTrinket(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), true)
  p:AddTrinket(item);
end

-- Give heart function
helper.giveHeart = function (name)
  
  local p = Isaac.GetPlayer(0);
  
  if name == "Red" then p:AddHearts(2)
  elseif name == "Container" then p:AddMaxHearts(2, true)
  elseif name == "Soul" then p:AddSoulHearts(2)
  elseif name == "Golden" then p:AddGoldenHearts(1)
  elseif name == "Eternal" then p:AddEternalHearts(1)
  elseif name == "Bone" then p:AddBoneHearts(1)
  elseif name == "Twitch" then
  
    -- Copying black heart mechanic
    if ( p:GetSoulHearts() % 2 == 1) then
      p:AddSoulHearts(1)
      ITMR.Storage.Hearts.twitch = ITMR.Storage.Hearts.twitch + 1;
    else
      ITMR.Storage.Hearts.twitch = ITMR.Storage.Hearts.twitch + 2;
    end
    
  elseif name == "Black" then p:AddBlackHearts(2) end
end

-- Give pickup function
helper.givePickup = function (name, count)
  local p = Isaac.GetPlayer(0);
  if name == "Coin" then p:AddCoins(count)
  elseif name == "Bomb" then p:AddBombs(count)
  elseif name == "Key" then p:AddKeys(count) end
end

-- Give companion function
helper.giveCompanion = function (name, count)
  
  local p = Isaac.GetPlayer(0);
  local game = Game()
  local room = game:GetRoom()
  
  if name == "Spider" then
    for i = 0, 5 do
      p:AddBlueSpider(room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true))
    end
    
  elseif name == "Fly" then
    p:AddBlueFlies(5, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), p)
    
  elseif name == "BadFly" then
    
    for i = 0, 5 do
      local c = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0,  0, room:GetCenterPos(), Vector(0, 0), p)
      c:ToNPC().MaxHitPoints = p.Damage * 5
      c:ToNPC().HitPoints = p.Damage * 5
    end
    
    helper.closeDoors()
    
  elseif name == "BadSpider" then
    
    for i = 0, 5 do
      local c = Isaac.Spawn(EntityType.ENTITY_SPIDER, 0,  0, room:FindFreePickupSpawnPosition(room:GetCenterPos(), 0, true), Vector(0, 0), p)
      c:ToNPC().MaxHitPoints = p.Damage * 5
      c:ToNPC().HitPoints = p.Damage * 5
    end
    
    helper.closeDoors()
    
  elseif name == "PrettyFly" then p:AddPrettyFly() end
  
end

-- Give pocket or effect function
helper.givePocket = function (name)
  local p = Isaac.GetPlayer(0);
  if name == "LuckUp" then p:DonateLuck(1)
  elseif name == "LuckDown" then p:DonateLuck(-1)
  elseif name == "Pill" then p:AddPill(math.random(1, PillColor.NUM_PILLS))
  elseif name == "Card" then p:AddCard(math.random(1, Card.CARD_RANDOM))
  elseif name == "Spacebar" and p:GetActiveItem() ~= CollectibleType.COLLECTIBLE_NULL then p:UseActiveItem (p:GetActiveItem(), true, true, true, true)
  elseif name == "Charge" then p:FullCharge()
  elseif name == "Discharge" then p:DischargeActiveItem() end
end

-- Launch event function
helper.launchEvent = function (eventName)
  
  local event = ITMR.Events[eventName]
  
  -- Create new ActiveEvent
  local ev = ITMR.Classes.ActiveEvent:new(event, eventName)
  
  -- Trigger onStart and onRoomChange callbacks, if it possible
  if ev.event.onStart ~= nil then ev.event.onStart() end
  if ev.event.onRoomChange ~= nil then ev.event.onRoomChange() end
  
  -- Bind dynamic callbacks
  ITMR.DynamicCallbacks.bind(ITMR.Events, eventName)
  
  -- Add ActiveEvent to current events storage
  table.insert(ITMR.Storage.ActiveEvents, ev)
  
end

-- Close doors function
helper.closeDoors = function ()
  local room = Game():GetRoom()
  
  room:SetClear(false)
  for i = 0,DoorSlot.NUM_DOOR_SLOTS-1 do
    local door = room:GetDoor(i)
    if door ~= nil then
      door:Close() 
    end
  end
end

-- Reset mod state
helper.resetState = function ()
  
  -- Reset dynamic callbacks
  for cname, cval in pairs(ITMR.DynamicCallbacks) do
    if (type(cval) ~= "function") then
      cval = nil
    end
  end
  
  -- Disable shaders
  for shaderName, shader in pairs(ITMR.Shaders) do
    shader.enabled = false
  end
  
  -- Clear current collectible items count
  for key,value in pairs(ITMR.Items.Passive) do
    ITMR.Items.Passive[key].count = 0
  end
    
  -- Reset stats
  ITMR.Storage.Stats = {
    speed = 0,
    range = 0,
    tears = 0,
    tearspeed = 0,
    damage = 0,
    luck = 0
  }
  
  -- Reset hearts
  ITMR.Storage.Hearts = {
    twitch = 0,
    rainbow = 0
  }
  
  -- Reset events
  ITMR.Storage.ActiveEvents = {}
  
  -- Reset familiars
  ITMR.Storage.ActiveEvents = {}
  
end

-- Fix text (check if Russian font available)
helper.fixtext = function (text)
  if (Isaac.GetTextWidth("�") ~= 5) then
    text = helper.translitrus(text)
  else
    text = helper.fixrus(text)
  end
  
  return text
end

-- Convert russian letters from utf-8 to win-1251. Oh my god...
helper.fixrus = function (str)
  str = str:gsub('а', '�')
  str = str:gsub('б', '�')
  str = str:gsub('в', '�')
  str = str:gsub('г', '�')
  str = str:gsub('д', '�')
  str = str:gsub('е', '�')
  str = str:gsub('ё', '�')
  str = str:gsub('ж', '�')
  str = str:gsub('з', '�')
  str = str:gsub('и', '�')
  str = str:gsub('й', '�')
  str = str:gsub('к', '�')
  str = str:gsub('л', '�')
  str = str:gsub('м', '�')
  str = str:gsub('н', '�')
  str = str:gsub('о', '�')
  str = str:gsub('п', '�')
  str = str:gsub('р', '�')
  str = str:gsub('с', '�')
  str = str:gsub('т', '�')
  str = str:gsub('у', '�')
  str = str:gsub('ф', '�')
  str = str:gsub('х', '�')
  str = str:gsub('ц', '�')
  str = str:gsub('ч', '�')
  str = str:gsub('ш', '�')
  str = str:gsub('щ', '�')
  str = str:gsub('ъ', '�')
  str = str:gsub('ы', '�')
  str = str:gsub('ь', '�')
  str = str:gsub('э', '�')
  str = str:gsub('ю', '�')
  str = str:gsub('я', '�')
  
  str = str:gsub('А', '�')
  str = str:gsub('Б', '�')
  str = str:gsub('В', '�')
  str = str:gsub('Г', '�')
  str = str:gsub('Д', '�')
  str = str:gsub('Е', '�')
  str = str:gsub('Ё', '�')
  str = str:gsub('Ж', '�')
  str = str:gsub('З', '�')
  str = str:gsub('И', '�')
  str = str:gsub('Й', '�')
  str = str:gsub('К', '�')
  str = str:gsub('Л', '�')
  str = str:gsub('М', '�')
  str = str:gsub('Н', '�')
  str = str:gsub('О', '�')
  str = str:gsub('П', '�')
  str = str:gsub('Р', '�')
  str = str:gsub('С', '�')
  str = str:gsub('Т', '�')
  str = str:gsub('У', '�')
  str = str:gsub('Ф', '�')
  str = str:gsub('Х', '�')
  str = str:gsub('Ц', '�')
  str = str:gsub('Ч', '�')
  str = str:gsub('Ш', '�')
  str = str:gsub('Щ', '�')
  str = str:gsub('Ъ', '�')
  str = str:gsub('Ы', '�')
  str = str:gsub('Ь', '�')
  str = str:gsub('Э', '�')
  str = str:gsub('Ю', '�')
  str = str:gsub('Я', '�')
  
  return str
end

-- Convert russian letters to english translit. OH. MY. GOD.
helper.translitrus = function (str)
  str = str:gsub('а', 'a')
  str = str:gsub('б', 'b')
  str = str:gsub('в', 'v')
  str = str:gsub('г', 'g')
  str = str:gsub('д', 'd')
  str = str:gsub('е', 'e')
  str = str:gsub('ё', 'yo')
  str = str:gsub('ж', 'zh')
  str = str:gsub('з', 'z')
  str = str:gsub('и', 'i')
  str = str:gsub('й', 'y')
  str = str:gsub('к', 'k')
  str = str:gsub('л', 'l')
  str = str:gsub('м', 'm')
  str = str:gsub('н', 'n')
  str = str:gsub('о', 'o')
  str = str:gsub('п', 'p')
  str = str:gsub('р', 'r')
  str = str:gsub('с', 's')
  str = str:gsub('т', 't')
  str = str:gsub('у', 'u')
  str = str:gsub('ф', 'f')
  str = str:gsub('х', 'h')
  str = str:gsub('ц', 'c')
  str = str:gsub('ч', 'ch')
  str = str:gsub('ш', 'sh')
  str = str:gsub('щ', 'sch')
  str = str:gsub('ъ', '|')
  str = str:gsub('ы', 'i')
  str = str:gsub('ь', '`')
  str = str:gsub('э', 'e')
  str = str:gsub('ю', 'yu')
  str = str:gsub('я', 'ya')
  
  str = str:gsub('А', 'A')
  str = str:gsub('Б', 'B')
  str = str:gsub('В', 'V')
  str = str:gsub('Г', 'G')
  str = str:gsub('Д', 'D')
  str = str:gsub('Е', 'E')
  str = str:gsub('Ё', 'Yo')
  str = str:gsub('Ж', 'Zh')
  str = str:gsub('З', 'Z')
  str = str:gsub('И', 'I')
  str = str:gsub('Й', 'Y')
  str = str:gsub('К', 'K')
  str = str:gsub('Л', 'L')
  str = str:gsub('М', 'M')
  str = str:gsub('Н', 'N')
  str = str:gsub('О', 'O')
  str = str:gsub('П', 'P')
  str = str:gsub('Р', 'R')
  str = str:gsub('С', 'S')
  str = str:gsub('Т', 'T')
  str = str:gsub('У', 'U')
  str = str:gsub('Ф', 'F')
  str = str:gsub('Х', 'H')
  str = str:gsub('Ц', 'C')
  str = str:gsub('Ч', 'Ch')
  str = str:gsub('Ш', 'Sh')
  str = str:gsub('Щ', 'Sch')
  str = str:gsub('Ъ', '|')
  str = str:gsub('Ы', 'I')
  str = str:gsub('Ь', '`')
  str = str:gsub('Э', 'E')
  str = str:gsub('Ю', 'Yu')
  str = str:gsub('Я', 'Ya')
  
  return str
end

return helper
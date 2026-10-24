local PLUGIN = PLUGIN

util.AddNetworkString("ixvenKGSync")
util.AddNetworkString("ixvenKGRequest")
util.AddNetworkString("ixvenKGOpenNPC")
util.AddNetworkString("ixvenKGNPCClaim")
util.AddNetworkString("ixvenKGQuestClaim")

-- ikonları server side yükleme yeri
for _, d in ipairs(ix.ven.kg.DisciplineList) do
    if d.icon and file.Exists("materials/" .. d.icon, "GAME") then
        resource.AddFile("materials/" .. d.icon)
    end
end

-- Ödül alınca asa sisteminden büyü verme

function ix.ven.kg.GiveSpell(client, spell)
    if ix.ven.kg.Config.GiveSpell then 
        return ix.ven.kg.Config.GiveSpell(client, spell)
    end

    if not HpwRewrite then return false end

    if isfunction(client.LearnSpell) then
        client:LearnSpell(spell)
        return true
    elseif isfunction(HpwRewrite.LearnSpell) then
        HpwRewrite:LearnSpell(client, spell)
        return true
    end

    MsgC(Color(22, 58, 188, 246), "[Diestra Roleplay] Büyü verilemedi: '" .. spell .. "'. Config.GiveSpell tanimlayin.\n")
    return false
end


-- seviyesine gelinen tüm büyüleri tekrar verir karakter yüklenince ve doğunca call atar büyüler kalıcı kalıo işte aq
function ix.ven.kg.ApplySpells(client, character)
    local data = character.venkgData
    if not data or not data.loaded then return end

    for _, d in ipairs(ix.ven.kg.DisciplineList) do
        local lvl = ix.ven.kg.GetLevel(d.id, data.xp[d.id] or 0)
        for i = 1, lvl do 
            for _, spell in ipairs(d.levels[i]. spells or {}) do
                ix.ven.kg.GiveSpell(client, spell)
            end
        end 
    end
end


-- xp seviye şeysi
local function GetData(client)
    local char = client:GetCharacter()
    if not char or not char.venkgData or not char.venkgData.loaded then return end
    return char, char.venkgData
end

function ix.ven.kg.GrantLevelRewards(client, disc, level)
    local d = ix.ven.kg.Disciplines[disc]
    local lvl = d.levels[level]
    client:Notify(d.name .. " seviye " .. level .. "oldun !")

    for _, text in ipairs(lvl.rewards or {}) do
        client:ChatPrint("[" .. d.name .. " Sv." .. level .. "] " .. text)
    end

    for _, spell in ipairs(lvl.spells or {}) do
        ix.ven.kg.GiveSpell(client, spell)
        client:ChatPrint("[" .. d.name .. "Sv." .. level .. "] Öğrendiğin büyü: " .. spell)
    end 
end

function ix.ven.kg.AddXP(client, disc, amount)
    local char, data = GetData(client)
    if not char or not ix.ven.kg.Disciplines[disc] or amount <= 0 then return false end 

    local old = data.xp[disc] or 0
    local new = math.min(old + amount, ix.ven.kg.GetMaxXP(disc))
    if new == old then return false end 

    data.xp[disc] = new
    ix.ven.kg.SaveXP(char:GetID(), disc, new)

    local oldLvl, newLvl = ix.ven.kg.GetLevel(disc, old), ix.ven.kg.GetLevel(disc, new)
    for lvl = oldLvl + 1, newLvl do
        ix.ven.kg.GrantLevelRewards(client, disc, lvl)
    end

    ix.ven.kg.AddQuestProgress(client, "xp", disc, new - old)
    ix.ven.kg.Sync(client)
    return true
end

function ix.ven.kg.ReadBook(client, disc, tierID)
    local char, data = GetData(client)
    local d = ix.ven.kg.Disciplines[disc]
    local tier = ix.ven.kg.BookTiers[tierID or 1] or ix.ven.kg.BookTiers[1]

    if not char or not d then
        client:Notify("Karakter verilerin henüz yüklenmedi. Eğer bu sorun devam ederse Discord'tan ticket aç.")
        return false
    end

    local xp = data.xp[disc] or 0
    if xp >= ix.ven.kg.GetMaxXP(disc) then
        client:Notify(d.name .. " bu karakter gelişiminde zaten en üst seviyedesin.")
        return false
    end 

    local req = tier.reqLevel or 1
    if ix.ven.kg.Config.BookRequireLevel and ix.ven.kg.GetLevel(disc, xp) < req then 
        client:Notify("Bu kitabı anlamak için " .. d.name .. " seviyen en az " .. req .. " olmalı.")
        return false
    end
    
    local gain = math.floor(tier.xp * (d.bookXPMult or 1))
    ix.ven.kg.AddXP(client, disc, gain)
    ix.ven.kg.AddQuestProgress(client, "book", disc, 1)
    client:Notify(d.name .. " kitabını (" .. tier.name ..") okudun. +" .. gain .. " XP")

    return ix.ven.kg.Config.ConsumeBook
end

function ix.ven.kg.TeachClass(teacher, disc, xp)
    xp = xp or ix.ven.kg.Config.ClassXP
    local r2 = ix.ven.kg.Config.ClassRadius ^ 2
    local count = 0

    for _, ply in ipairs(player.GetAll()) do
        if ply ~= teacher and ply:GetCharacter() and ply:GetPos():DistToSqr(teacher:GetPos()) <= r2 then
            ix.ven.kg.AddXP(ply, disc, xp)
            ix.ven.kg.AddQuestProgress(ply, "class", disc, 1)
            ply:Notify(ix.ven.kg.Disciplines[disc].name .. " dersine katıldın. +" .. xp .. " XP")
            count = count + 1
        end
    end 
    return count
end


-- Görevler
function ix.ven.kg.PeriodKey(period)
    if period == "daily" then return os.date("%Y-%m-%d") end
    if period == "weekly" then return os.date("%Y-W%W") end
    return os.date("%Y-%m")
end

function ix.ven.kg.GetQuestState(char, q)
    local quests = char.venkgData.quests
    local key = ix.ven.kg.PeriodKey(q.period)
    local s = quests[q.id]

    if not s or s.key ~= key then
        s = {key = key, progress = 0, done = false, claimed = false}
        quests[q.id] = s
    end
    return s
end

function ix.ven.kg.AddQuestProgress(client, qtype, disc, amount)
    local char, data = GetData(client)
    if not char then return end

    for _, q in ipairs(ix.ven.kg.Quests) do
        if q.type == qtype and (not q.discipline or q.discipline == disc) then 
            local s = ix.ven.kg.GetQuestState(char, q)
            if not s.done then
                s.progress = math.min(s.progress + amount, q.amount)
                if s.progress >= q.amount then
                    s.done = true
                    client:Notify("Görev tamamlandı: " .. q.name .. "(Karakter Gelişimi sekmesinden ödülünü al.)")
                end
            ix.ven.kg.SaveQuest(char:GetID(), q.id, s)
            end
        end
    end 
end 

function ix.ven.kg.ClaimQuest(client, id)
    local char, data = GetData(client)
    local q = ix.ven.kg.QuestByID[id]
    if not char or not q then return end

    local s = ix.ven.kg.GetQuestState(char, q)
    if not s.done or s.claimed then return end 

    s.claimed = true
    ix.ven.kg.SaveQuest(char:GetID(), q.id, s)

    local r = q.reward or {}
    if r.money then char:GiveMoney(r.money) end
    for _, uid in ipairs(r.items or {}) do char:GetInventory():Add(uid) end
    for disc, amt in pairs(r.xp or {}) do ix.ven.kg.AddXP(client, disc, amt) end

    client:Notify("Görev ödülü alındı: " .. ix.ven.kg.RewardText(r))
    ix.ven.kg.Sync(client)
end




-- npc kitap vs.
function ix.ven.kg.GetCooldownRemaining(char, key)
    local cfg = ix.ven.kg.NPCs[key]
    local last = char.venkgData.cooldowns[key] or 0
    return math.max(0, (last + cfg.cooldown) - os.time())
end

function ix.ven.kg.OpenNPC(client, ent)
    local char, data = GetData(client)
    if not char then return client:Notify("Karakter verilerin yükleniyor, birkaç saniye sonra tekrar dene eğer çalışmazsa Discord üstünden ticket aç.") end

    net.Start("ixvenKGOpenNPC")
        net.WriteEntity(ent)
        net.WriteString(ent.venKGNPC)
        net.WriteUInt(ix.ven.kg.GetCooldownRemaining(char, ent.venKGNPC), 32)
    net.Send(client)
end

function ix.ven.kg.NPCClaim(client, key)
    local char, data = GetData(client)
    local cfg = ix.ven.kg.NPCs[key]
    if not char or not cfg then return end

    local remaining = ix.ven.kg.GetCooldownRemaining(char, key)
    if remaining > 0 then
        return client:Notify("Tekrar kitap almak için " .. ix.ven.kg.FormatTime(remaining) .. " beklemelisin.")
    end

    local inv = char:GetInventory()
    local given = {}

    for i = 1, (cfg.bookCount or 1) do
        local disc = ix.ven.kg.RollDiscipline(key)
        local tierID = ix.ven.kg.RollTier()

        if disc then
            if inv:Add("ven_kg_" .. disc, 1, {tier = tierID}) then
                local d, tier = ix.ven.kg.Disciplines[disc],  ix.ven.kg.BookTiers[tierID]
                given[#given + 1] = (d.bookName or (d.name .. "Kitabı")) .. " (" .. tier.name .. ")"
            else
                client:Notify("Envanterinde yer kalmadığı için kitaplar verilemedi.")
                break
            end
        end 
    end 

    if #given > 0 then 
        local now = os.time()
        data.cooldowns[key] = now
        ix.ven.kg.SaveCooldown(char:GetID(), key, now)
        client:Notify(cfg.name .. " sana şunlar verildi: ".. table.concat(given, ", "))
    end
end

net.Receive("ixvenKGNPCClaim", function(_, client)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not ent.venKGNPC then return end
    if client:GetPos():DistToSqr(ent:GetPos()) > ix.ven.kg.Config.NPCUseDistance ^ 2 then return end 
    ix.ven.kg.NPCClaim(client, ent.venKGNPC)
end)

net.Receive("ixvenKGQuestClaim", function(_, client)
    ix.ven.kg.ClaimQuest(client, net.ReadString())
end)



-- Senkronizasyon şeyi
function ix.ven.kg.Sync(client)
    local char, data = GetData(client)
    if not char then return end

    local out = {xp = data.xp, cooldowns = data.cooldowns, quests = {}}
    for _, q in ipairs(ix.ven.kg.Quests) do
        local s = ix.ven.kg.GetQuestState(char, q)
        out.quests[q.id] = {p = s.progress, d = s.done, c = s.claimed}
    end

    net.Start("ixvenKGSync")
        net.WriteTable(out)
    net.Send(client)
end

net.Receive("ixvenKGRequest", function(_, client)
    ix.ven.kg.Sync(client)
end)




-- Hooklar
function PLUGIN:PlayerLoadedCharacter(client, character)
    ix.ven.kg.LoadCharacter(client, character)
end

function PLUGIN:PlayerSpawn(client)
    timer.Simple(1, function()
        if IsValid(client) and client:GetCharacter() then
            ix.ven.kg.ApplySpells(client, client:GetCharacter())
        end
    end)
end

-- npc şeyi
function PLUGIN:SaveData()
    local data = {}
    for _, cfg in pairs(ix.ven.kg.NPCs) do
        for _, ent in ipairs(ents.FindByClass(cfg.class)) do
            data[#data + 1] = {class = cfg.class, pos = ent:GetPos(), ang = ent:GetAngles()}
        end 
    end
    self:SetData(data)
end

function PLUGIN:LoadData()
    for _, v in ipairs(self:GetData() or {}) do
        local ent = ents.Create(v.class)
        if IsValid(ent) then
            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()
        end
    end
end 
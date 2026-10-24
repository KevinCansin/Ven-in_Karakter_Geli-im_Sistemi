local PLUGIN = PLUGIN

function ix.ven.kg.Str(s)
    return "'" .. mysql:Escape(tostring(s)) .. "'"
end

function PLUGIN:DatabaseConnected()
    mysql:RawQuery([[CREATE TABLE IF NOT EXISTS `ix_ven_kg_progress` (
        `char_id` INT NOT NULL,
        `discipline` VARCHAR(32) NOT NULL,
        `xp` INT NOT NULL DEFAULT 0,        
        PRIMARY KEY (`char_id`, `discipline`))]])

    mysql:RawQuery([[CREATE TABLE IF NOT EXISTS `ix_ven_kg_quests` (
        `char_id` INT NOT NULL,
        `quest_id` VARCHAR(48) NOT NULL,
        `period_key` VARCHAR(16) NOT NULL,
        `progress` INT NOT NULL DEFAULT 0,
        `done` INT NOT NULL DEFAULT 0,
        `claimed` INT NOT NULL DEFAULT 0,
        PRIMARY KEY (`char_id`, `quest_id`))]])

    mysql:RawQuery([[CREATE TABLE IF NOT EXISTS `ix_ven_kg_cooldowns` (
        `char_id` INT NOT NULL,
        `npc` VARCHAR(32) NOT NULL,
        `last_take` BIGINT NOT NULL DEFAULT 0,
        PRIMARY KEY (`char_id`, `npc`))]])

end

function ix.ven.kg.SaveXP(charID, disc, xp)
    mysql:RawQuery(string.format("REPLACE INTO `ix_ven_kg_progress` (`char_id`, `discipline`, `xp`) VALUES (%d, %s, %d)",
        charID, ix.ven.kg.Str(disc), xp))
end

function ix.ven.kg.SaveQuest(charID, id, s)
    mysql:RawQuery(string.format(
        "REPLACE INTO `ix_ven_kg_quests` (`char_id`, `quest_id`, `period_key`, `progress`, `done`, `claimed`) VALUES (%d, %s, %s, %d, %d, %d)",
        charID, ix.ven.kg.Str(id), ix.ven.kg.Str(s.key), s.progress, s.done and 1 or 0, s.claimed and 1 or 0))
end

function ix.ven.kg.SaveCooldown(charID, npc, t)
    mysql:RawQuery(string.format("REPLACE INTO `ix_ven_kg_cooldowns` (`char_id`, `npc`, `last_take`) VALUES (%d, %s, %d)",
        charID, ix.ven.kg.Str(npc), t))
end

function ix.ven.kg.LoadCharacter(client, character)
    local id = character:GetID()
    local data = {xp = {}, quests = {}, cooldowns = {}, loaded = false}
    character.venkgData = data

    local pending = 3
    local function finish()
        pending = pending - 1
        if pending > 0 then return end

        data.loaded = true
        if IsValid(client) and client:GetCharacter() == character then
            ix.ven.kg.ApplySpells(client, character)
            ix.ven.kg.Sync(client)
        end
    end 

    mysql:RawQuery("SELECT `discipline`, `xp` FROM `ix_ven_kg_progress` WHERE `char_id` = " .. id, function(rows)
        for _, r in ipairs(rows or {}) do
            data.xp[r.discipline] = tonumber(r.xp) or 0
        end
        finish()
    end)

    mysql:RawQuery("SELECT `quest_id`, `period_key`, `progress`, `done`, `claimed` FROM `ix_ven_kg_quests` WHERE `char_id` = " .. id, function(rows)
        for _, r in ipairs(rows or {}) do
            data.quests[r.quest_id] = {
                key = r.period_key,
                progress = tonumber(r.progress) or 0,
                done = tonumber(r.done) == 1,
                claimed = tonumber(r.claimed) == 1
            }
        end
        finish()
    end)

    mysql:RawQuery("SELECT `npc`, `last_take` FROM `ix_ven_kg_cooldowns` WHERE `char_id` = " .. id, function(rows)
        for _, r in ipairs(rows or {}) do
            data.cooldowns[r.npc] = tonumber(r.last_take) or 0
        end
        finish()
    end)
end
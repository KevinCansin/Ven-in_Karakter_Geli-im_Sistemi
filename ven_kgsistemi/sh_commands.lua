local PLUGIN = PLUGIN

ix.command.Add("venkgnpcekle", {
    description = "Baktığın yere kütüphaneci ya da lanet satan eleman ekler.",
    adminOnly = true,
    arguments = ix.type.string,
    OnRun = function(self, client, key)
        key = key:lower()
        local cfg = ix.ven.kg.NPCs[key]
        if not cfg then return "Geçersiz NPC. Npcler: libary, curse" end

        local ent = ents.Create(cfg.class)
        ent:SetPos(client:GetEyeTrace().HitPos + Vector(0, 0, 4))
        local ang = (client:GetPos() - ent:GetPos()):Angle()
        ang.p, ang.r = 0, 0
        ent:SetAngles(ang)
        ent:Spawn()

        PLUGIN:SaveData()
        return cfg.name .. " eklendi."
    end
})

ix.command.Add("venkgnpcsil", {
    description = "Baktığın kütüphaneciyi siler.",
    adminOnly = true,
    OnRun = function(self, client)
        local ent = client:GetEyeTrace().Entity
        if IsValid(ent) and ent.venKGNPC then
            ent:Remove()
            PLUGIN:SaveData()
            return "Npc silindi."
        end
        return "Bir kütüphaneciye bakman lazım bro."
    end
})

ix.command.Add("venkgxpver", {
    description = "Oyuncuya karakter gelişimi xpsi verir.",
    adminOnly = true,
    arguments = {ix.type.character, ix.type.string, ix.type.number},
    OnRun = function(self, client, target, disc, amount)
        disc = disc:lower()
        if not ix.ven.kg.Disciplines[disc] then return "Böyle bir yönelim bulunmamakta." end
        local ply = target:GetPlayer()
        if not IsValid(ply) then return "Oyuncu yok." end
        ix.ven.kg.AddXP(ply, disc, math.max(0, math.floor(amount)))
        return ply:Name() .. " kişisine " .. amount ..  " " .. disc .. " XP verildi."
    end
})

ix.command.Add("venkgders", { 
    description = "Yakındaki herkese ders XP'si verir.",
    arguments = {ix.type.string, bit.bor(ix.type.number, ix.type.optional)},
    OnCheckAccess = function(self, client)
        local char = client:GetCharacter()
        return client:IsAdmin() or (char and char:HasFlags(ix.ven.kg.Config.TeachFlag)) or false
    end,
    OnRun = function(self, client, disc, xp)
        disc = disc:lower()
        if not ix.ven.kg.Disciplines[disc] then return "Geçersiz ders." end
        local count = ix.ven.kg.TeachClass(client, disc, xp)
        return count .. " öğrenciye ders XP'si verildi."
    end 
})
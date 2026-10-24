ix.ven.kg.ClientData = ix.ven.kg.ClientData or {xp = {}, quests = {}, cooldowns = {} }

function ix.ven.kg.GetClientXP(disc)
    return ix.ven.kg.ClientData.xp[disc] or 0
end

net.Receive("ixvenKGSync", function()
    ix.ven.kg.ClientData = net.ReadTable()
    ix.ven.kg.ClientData.loaded = true

    if IsValid(ix.ven.gui.kgMain) then
        ix.ven.gui.kgMain:Refresh()
    end
end)

net.Receive("ixvenKGOpenNPC", function()
    local ent = net.ReadEntity()
    local key = net.ReadString()
    local remaining = net.ReadUInt(32)

    if IsValid(ix.ven.gui.kgNPC) then ix.ven.gui.kgNPC:Remove() end

    local panel = vgui.Create("ixvenKGNPCMenu")
    panel:Setup(ent, key, remaining)
    ix.ven.gui.kgNPC = panel
end)
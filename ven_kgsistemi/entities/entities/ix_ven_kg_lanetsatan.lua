AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Kötü Kütüphaneci"
ENT.Category = "Ven'in Karakter Gelişimi"
ENT.Spawnable = true
ENT.bNoPersist = true
ENT.venKGNPC = "curse"
ENT.PopulateEntityInfo = true

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/humans/group01/male_02.mdl")
        self:SetUseType(SIMPLE_USE)
        self:SetMoveType(MOVETYPE_NONE)
        self:DrawShadow(true)
        self:SetSolid(SOLID_BBOX)

        timer.Simple(1, function()
            if not IsValid(self) then return end
            for i, seq in ipairs(self:GetSequenceList()) do
                if seq:lower():find("idle") and seq:lower() ~= "idlenoise" then
                    self:ResetSequence(i)
                    return
                end
            end
            self:ResetSequence(4)
        end)
    end

    function ENT:Use(activator)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if (self.nextUse or 0) > CurTime() then return end
        self.nextUse = CurTime() + 1
        ix.ven.kg.OpenNPC(activator, self)
    end
else
    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:OnPopulateEntityInfo(container)
        local cfg = ix.ven.kg.NPCs[self.venKGNPC] or {}

        local name = container:AddRow("name")
        name:SetImportant()
        name:SetText(cfg.name or "NPC")
        name:SizeToContents()

        local desc = container:AddRow("description")
        desc:SetText(cfg.desc or "31")
        desc:SizeToContents()
    end
end
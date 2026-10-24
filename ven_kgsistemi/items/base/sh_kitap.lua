ITEM.name = "Kitap"
ITEM.description = "Bir ders kitabı"
ITEM.model = "models/props_lab/binderblue.mdl" -- kitap modeli koy
ITEM.width = 1
ITEM.height = 1
ITEM.category = "kitaplar"
ITEM.venKGDiscipline = nil 

function ITEM:GetTier()
    local id = self:GetData("tier", 1)
    return id, ix.ven.kg.BookTiers[id] or ix.ven.kg.BookTiers[1]
end

function ITEM:GetName()
    local d = ix.ven.kg and ix.ven.kg.Disciplines[self.venKGDiscipline]
    if not d then return self.name end

    local _, tier = self:GetTier()
    return (d.bookName or (d.name .. " Kitabı")) .. "(".. tier.name ..")"
end

function ITEM:GetDescription()
    local d = ix.ven.kg and ix.ven.kg.Disciplines[self.venKGDiscipline]
    if not d then return self.description end

    local _, tier = self:GetTier()
    local xp = math.floor(tier.xp * (d.bookXPMult or 1))
    local text = d.bookDesc or ("Okuyarak " .. d.name .. " yöneliminde ilerleme kaydedebilirsin.")
    return text .. "\nKitap seviyesi: " .. tier.name .. "| Verdiği XP: " .. xp
end

ITEM.functions.Read = {
    name = "Oku",
    icon = "icon16/book_open.png",
    OnRun = function(item)
        return ix.ven.kg.ReadBook(item.player, item.venKGDiscipline, (item:GetTier()))
    end,
    OnCanRun = function(item)
        return not IsValid(item.entity)
    end
}
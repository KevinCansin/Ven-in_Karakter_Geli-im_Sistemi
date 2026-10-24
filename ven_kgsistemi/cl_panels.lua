local PLUGIN = PLUGIN
local T = ix.ven.kg.Config.Theme

-- helper
local matCache = {}

function ix.ven.kg.GetMaterial(path)
    if not path then return end
    if matCache[path] == nil then
        local m = Material(path, "smooth mips")
        matCache[path] = (m and not m:IsError()) and m or false
    end
    return matCache[path] or nil
end

local function DrawIcon(disc, x, y, s)
    local d = ix.ven.kg.Disciplines[disc]
    local mat = ix.ven.kg.GetMaterial(d.icon)

    if mat then
        surface.SetDrawColor(255,255,255)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(x, y, s, s)
    else 
        draw.RoundedBox(6, x, y, s, s, d.color or T.accent)
        draw.SimpleText(utf8.char(utf8.codepoint(d.name, 1)), "ixBigFont", x + s / 2, y + s / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function DrawBar(x, y, w, h, frac, col)
    surface.SetDrawColor(0, 0, 0, 170)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(col)
    surface.DrawRect(x + 1, y + 1, math.max(0, (w - 2) * math.Clamp(frac, 0, 1)), h - 2)
end

local function Wrap(text, font, maxW)
    surface.SetFont(font)
    local lines, cur = {}, ""

    for word in string.gmatch(text, "%S+") do
        local test = cur == "" and word or (cur .. " " .. word)
        if surface.GetTextSize(test) > maxW and cur ~= "" then 
            lines[#lines + 1] = cur
            cur = word
        else
            cur = test
        end
    end 
    if cur ~= "" then lines[#lines + 1] = cur end
    return lines
end

local function StyleButton(btn, label)
    btn:SetText("")
    btn.Paint = function(s, w, h)
        local col = T.card
        if not s:IsEnabled() then col = Color(25, 25, 32, 240)
        elseif s:IsHovered() then col = Color(55, 55, 72, 245) end
        draw.RoundedBox(4, 0, 0, w, h, col)
        draw.SimpleText(isfunction(label) and label() or label, "ixSmallFont", w/2, h/2,
            s:IsEnabled() and T.text or T.muted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end


-- kg kartımsı bir şey

local CARD = {}

function CARD:Init()
    self:SetTall(96)
    self:Dock(TOP)
    self:DockMargin(0, 0, 8, 8)
end 

function CARD:SetDiscipline(id) self.disc = id end 

function CARD:Paint(w, h)
    local d = ix.ven.kg.Disciplines[self.disc]
    local xp = ix.ven.kg.GetClientXP(self.disc)
    local lvl, into, need = ix.ven.kg.GetProgress(self.disc, xp)
    local x = h

    draw.RoundedBox(6, 0, 0, w, h, T.card)
    DrawIcon(self.disc, 12, 12, h - 24)

    draw.SimpleText(d.name, "ixMediumFont", x, 10, T.text)
    draw.SimpleText("Seviye " .. lvl .. " / " .. ix.ven.kg.GetMaxLevel(self.disc), "ixSmallFont", w - 14, 14, T.accent, TEXT_ALIGN_RIGHT)
    draw.SimpleText(d.desc or "", "ixSmallFont", x, 40, T.muted)

    local by = h - 30
    DrawBar(x, by, w - x - 14, 16, need and (into / need) or 1, d.color or T.accent)
    draw.SimpleText(need and (into .. " / " .. need .. " XP") or "Maks Seviye", "ixSmallFont",
        x + (w - x - 14) / 2, by + 8, T.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("ixvenKGDisciplineCard", CARD, "DPanel")



-- Yönelimler

local DISC = {}

function DISC:Init()
    for _, d in ipairs(ix.ven.kg.DisciplineList) do 
        self:Add("ixvenKGDisciplineCard"):SetDiscipline(d.id)
    end
end 

vgui.Register("ixvenKGDisciplines", DISC, "DScrollPanel")




-- seviye ödül yeri 

local ROW = {}

function ROW:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 8, 8)
    self:SetTall(70)
    self.lines = {}
end

function ROW:SetData(disc, level)
    self.disc, self.level = disc, level
    self.levelData = ix.ven.kg.Disciplines[disc].levels[level]
end

function ROW:PerformLayout(w, h)
    if not self.levelData then return end
    
    local lines ={}
    for _, text in ipairs(self.levelData.rewards or {}) do
        for i, ln in ipairs(Wrap(text, "ixSmallFont", w -40)) do
            lines [#lines + 1] = {text = (i == 1 and "- " or "  ") .. ln, col = T.text}
        end
    end
    for _, spell in ipairs(self.levelData.spells or {}) do
        lines[#lines + 1] = { text = spell .. " adlı büyüyü öğrenirsin.", col = T.accent }
    end 

    self.lines = lines 
    local need = 40 + #lines * 18 + 8
    if h ~= need then self:SetTall(need) end
end 

function ROW:Paint(w, h)
    local xp = ix.ven.kg.GetClientXP(self.disc)
    local reached = ix.ven.kg.GetLevel(self.disc, xp) >= self.level
    local col = ix.ven.kg.Disciplines[self.disc].color or T.accent

    draw.RoundedBox(6, 0, 0, w, h, T.card)
    if reached then
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, 4, h)
    end

    draw.SimpleText("Seviye " .. self.level, "ixMediumFont", 16, 8, reached and T.text or T.muted)
    draw.SimpleText(self.levelData.xp .. "XP", "ixSmallFont", 130, 14, T.muted)
    draw.SimpleText(reached and "Açıldı" or "Kilitli", "ixSmallFont", w - 14, 14, reached and T.good or T.bad, TEXT_ALIGN_RIGHT)

    for i, ln in ipairs(self.lines) do
        draw.SimpleText(ln.text, "ixSmallFont", 20, 36 + (i - 1) * 18, reached and ln.col or T.muted)
    end
end

vgui.Register("ixvenKGLevelRow", ROW, "DPanel")



-- Ödüller sekmesi

local REW = {}

function REW:Init()
    self.selected = ix.ven.kg.DisciplineList[1] and ix.ven.kg.DisciplineList[1].id 

    self.side = self:Add("DScrollPanel")
    self.side:Dock(LEFT)
    self.side:SetWide(210)
    self.side:DockMargin(0, 0, 8, 0)

    for _, d in ipairs(ix.ven.kg.DisciplineList) do
        local b = self.side:Add("DButton")
        b:Dock(TOP)
        b:DockMargin(0, 0, 8, 6)
        b:SetTall(52)
        b:SetText("")
        b.Paint = function(s, w, h)
            local sel = self.selected == d.id
            draw.RoundedBox(4, 0, 0, w, h, sel and Color(55, 55, 72, 250) or (s:IsHovered() and Color(45,45,60,245) or T.card))
            if sel then
                surface.SetDrawColor(d.color or T.accent)
                surface.DrawRect(0, 0, 4, h)
            end
            DrawIcon(d.id, 10, 6, h - 12)
            draw.SimpleText(d.name, "ixSmallFont", h + 4, h / 2, T.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function()
            self.selected = d.id 
            self:Populate()
        end
    end

    self.list = self:Add("DScrollPanel")
    self.list:Dock(FILL)
    self:Populate()
end

function REW:Populate()
    self.list:Clear()
    if not self.selected then return end

    for i = 1, ix.ven.kg.GetMaxLevel(self.selected) do
        self.list:Add("ixvenKGLevelRow"):SetData(self.selected, i)
    end
end

vgui.Register("ixvenKGRewards", REW, "EditablePanel")




-- Görev Kısmı

local QROW = {}

function QROW:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 8, 8)
    self:SetTall(84)

    self.btn = self:Add("DButton")
    StyleButton(self.btn, "Ödülü Al")
    self.btn.DoClick = function()
        net.Start("ixvenKGQuestClaim")
            net.WriteString(self.quest.id)
        net.SendToServer()
    end
end 

function QROW:SetQuest(q) self.quest = q end

function QROW:PerformLayout(w, h)
    self.btn:SetPos(w - 130, h -34)
    self.btn:SetSize(118, 26)
end

function QROW:Paint(w, h)
    local q = self.quest
    local s = ix.ven.kg.ClientData.quests[q.id] or {p = 0, d = false, c = false}

    draw.RoundedBox(6, 0, 0, w, h, T.card)
    draw.SimpleText(q.name, "ixMediumFont", 14, 8, s.c and T.muted or T.text)
    draw.SimpleText(q.desc, "ixSmallFont", 14, 38, T.muted)
    draw.SimpleText("Ödül: " .. ix.ven.kg.RewardText(q.reward), "ixSmallFont", w - 14, 14, T.accent, TEXT_ALIGN_CENTER)


    local bw = w - 160
    DrawBar(14, h - 28, bw, 14, s.p / q.amount, s.d and T.good or T.accent)
    draw.SimpleText(s.p .. " / " .. q.amount, "ixSmallFont", 14 + bw / 2, h -21, T.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    self.btn:SetVisible(s.d and not s.c)
    if s.c then
        draw.SimpleText("Alındı", "ixSmallFont", w - 71, h - 21, T.good, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("ixvenKGQuestRow", QROW, "DPanel")





-- Görevler
local QUESTS = {}

function QUESTS:Init()
    for _, p in ipairs({{"daily", "Günlük Görevler"}, {"weekly", "Haftalık Görevler"}, {"monthly", "Aylık Görevler"}}) do
        local header = self:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(26)
        header:DockMargin(0, 4, 0, 6)
        header.Paint = function(s, w, h)
            draw.SimpleText(p[2], "ixMediumFont", 4, h / 2, T.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(T.accent.r, T.accent.g, T.accent.b, 90)
            surface.DrawRect(0, h - 1, w, 1)
        end 

        for _, q in ipairs(ix.ven.kg.Quests) do
            if q.period == p[1] then
                self:Add("ixvenKGQuestRow"):SetQuest(q)
            end
        end
    end
end

vgui.Register("ixvenKGQuests", QUESTS, "DScrollPanel")




-- Ana Panel

local MAIN = {}

local TABS = {
    {"Karakter Gelişimi", "ixvenKGDisciplines"},
    {"Ödüller", "ixvenKGRewards"},
    {"Görevler", "ixvenKGQuests"}
}

function MAIN:Init()
    ix.ven.gui.kgMain = self
    self:Dock(FILL)
    self.currentTab = TABS[1][2]

    self.nav = self:Add("EditablePanel")
    self.nav:Dock(TOP)
    self.nav:SetTall(40)
    self.nav:DockMargin(0, 0, 0, 10)

    for _, tab in ipairs(TABS) do
        local b = self.nav:Add("DButton")
        b:Dock(LEFT)
        b:DockMargin(0, 0, 8, 0)
        b:SetWide(160)
        b:SetText("")
        b.Paint = function(s, w, h)
            local sel = self.currentTab == tab[2]
            draw.RoundedBox(4, 0, 0, w, h, sel and T.accent or (s:IsHovered() and Color(55, 55, 72, 245) or T.card))
            draw.SimpleText(tab[1], "ixSmallFont", w / 2, h / 2, sel and Color(20, 20, 20) or T.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function() self:SetTab(tab[2]) end
    end

    self:SetTab(self.currentTab)
    
    if not ix.ven.kg.ClientData.loaded then 
        net.Start("ixvenKGRequest")
        net.SendToServer()
    end
end

function MAIN:SetTab(name)
    if IsValid(self.content) then self.content:Remove() end

    self.currentTab = name
    self.content = self:Add(name)
    self.content:Dock(FILL)
end

function MAIN:Refresh()
    self:SetTab(self.currentTab)
end

vgui.Register("ixvenKGMain", MAIN, "EditablePanel")

function PLUGIN:CreateMenuButtons(tabs)
    tabs["venkgTab"] = function(container)
        container:Add("ixvenKGMain")
    end
end



-- NPC menüsü
local NPC = {}

function NPC:Init()
    self:SetKeyboardInputEnabled(true)
    self:MakePopup()

    self.close = self:Add("DButton")
    StyleButton(self.close, "Kapat")
    self.close.DoClick = function() self:Remove() end

    self.claim = self:Add("DButton")
    StyleButton(self.claim, function()
        local rem = self.endTime - CurTime()
        return rem > 0 and ("Bekle: " .. ix.ven.kg.FormatTime(rem)) or "Kitapları Al"
    end)
    self.claim.DoClick = function()
        if IsValid(self.ent) then 
            net.Start("ixvenKGNPCClaim")
                net.WriteEntity(self.ent)
            net.SendToServer()
        end 
        self:Remove()
    end
end

function NPC:Setup(ent, key, remaining)
    self.ent, self.key = ent, key 
    self.cfg = ix.ven.kg.NPCs[key]
    self.endTime = CurTime() + remaining

    self.books = {}
    for _, d in ipairs(ix.ven.kg.DisciplineList) do 
        if (d.npc or "libary") == key then self.books[#self.books + 1] = d end
    end

    local w = math.min(560, ScrW() - 40)

    -- seviye ve düşme şansı
    local total, parts = 0, {}
    for _, t in ipairs(ix.ven.kg.BookTiers) do total = total + t.weight end
    for _, t in ipairs(ix.ven.kg.BookTiers) do
        parts[#parts + 1] = t.name .. " %" .. math.Round(t.weight / total * 100, 1) .. " (" .. t.xp .. "XP)"
    end
    self.infoLines = {"Her seferinde " .. (self.cfg.bookCount or 1) .. "rastgele kitap verilir."}
    for _, ln in ipairs(Wrap("Kitap seviyesi şansları: " .. table.concat(parts, ", "), "ixSmallFont", w - 36)) do
        self.infoLines[#self.infoLines + 1] = ln
    end
    
    local h = 96 + #self.books * 56 + 8 + #self.infoLines * 18 + 62
    self:SetSize(w, h)
    self:Center()
end 

function NPC:PerformLayout(w, h)
    self.close:SetPos(w - 130, h - 44)
	self.close:SetSize(116, 30)
	self.claim:SetPos(14, h - 44)
	self.claim:SetSize(w - 160, 30)
end

function NPC:Think()
	self.claim:SetEnabled(self.endTime - CurTime() <= 0)
end

function NPC:OnKeyCodePressed(key)
	if key == KEY_ESCAPE then
		self:Remove()
		gui.HideGameUI()
	end
end

function NPC:Paint(w, h)
	draw.RoundedBox(8, 0, 0, w, h, T.bg)
	draw.SimpleText(self.cfg.name, "ixBigFont", 18, 12, T.text)
	draw.SimpleText(self.cfg.desc or "", "ixSmallFont", 18, 52, T.muted)
	surface.SetDrawColor(T.accent.r, T.accent.g, T.accent.b, 110)
	surface.DrawRect(18, 82, w - 36, 1)

	for i, d in ipairs(self.books) do
		local y = 96 + (i - 1) * 56
		draw.RoundedBox(6, 14, y, w - 28, 50, T.card)
		DrawIcon(d.id, 20, y + 5, 40)
		draw.SimpleText(d.bookName or (d.name .. " Kitabı"), "ixMediumFont", 70, y + 6, T.text)
		draw.SimpleText(d.desc or "", "ixSmallFont", 70, y + 30, T.muted)
	end

	local y = 96 + #self.books * 56 + 8
	for i, ln in ipairs(self.infoLines) do
		draw.SimpleText(ln, "ixSmallFont", 18, y + (i - 1) * 18, i == 1 and T.accent or T.muted)
	end
end

vgui.Register("ixvenKGNPCMenu", NPC, "EditablePanel")

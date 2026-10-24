ix.ven.kg = ix.ven.kg or {}
ix.ven.kg.Disciplines = {}
ix.ven.kg.DisciplineList = {}
ix.ven.kg.Quests = {}
ix.ven.kg.QuestByID = {}

ix.ven.kg.Config = {
    BookRequireLevel = false, -- true atarsan seviyesi farklı olan kitaplar için farklı kg seviyesi olır.
    ClassXP = 40,             -- Bu daha yapım aşamasında derse girince ne kadar xp alacağının değeri
    ClassRadius = 300,        -- siktiret
    ConsumeBook = true,       -- Kitap okununca envanterden silinme.
    NPCUseDistance = 100,
    TeachFlag = "L",          -- Ders verme yetkisi flagi
    

    GiveSpell = function(client, spell) HpwRewrite:LearnSpell(client, spell) end, -- belki çalışmayabilir.

    Theme = {
       	bg      = Color(18, 18, 24, 235),
		card    = Color(34, 34, 46, 240),
		accent  = Color(200, 160, 70),
		text    = Color(235, 235, 235),
		muted   = Color(150, 150, 165),
		good    = Color(90, 190, 110),
		bad     = Color(190, 80, 80)
    }
}




-- Kitap seviyeleri

ix.ven.kg.BookTiers = {
    {name = "Seviye 1", xp = 5, weight = 50, reqLevel = 1},
    {name = "Seviye 2", xp = 10, weight = 30, reqLevel = 1},
    {name = "Seviye 3", xp = 15, weight = 14, reqLevel = 2},
    {name = "Seviye 4", xp = 30, weight = 5, reqLevel = 3},
    {name = "Seviye 5", xp = 40, weight = 1, reqLevel = 4},
}



-- Npcler

ix.ven.kg.NPCs = {
    libary = {
        name = "Kütüphaneci",
        desc = "Her 12 saatte bir ders kitabı verir.",
        model = "models/humans/group01/male_02.mdl",
        class = "ix_ven_kg_kutuphaneci",
        bookCount = 3,
        cooldown =  12 * 60 * 60
    },
    curse = {
        name = "Kötü Kütüphaneci",
        desc = "Lanet kitabı veren kişi",
        model = "models/humans/group01/male_07.mdl",
        class = "ix_ven_kg_lanetsatan",
        bookCount = 1,
        cooldown = 12 * 60 * 60
    }
}




-- kgler

local function Reg(id, data)
    data.id = id 
    ix.ven.kg.Disciplines[id] = data
    ix.ven.kg.DisciplineList[#ix.ven.kg.DisciplineList + 1] = data
end

Reg("ksks", {
    name = "Karanlık Sanatlara Karşı Savunma",
    desc = "",
    icon = "materials/ksks.png",
    color = Color(32, 27, 27, 193),
    levels = {
        {xp = 0, rewards = {"Temel KSKS bilgisi edinirsin."}},
        {xp = 100, rewards = {"Stupefy, Expelliarmus, Reducto ve Flipendo büyülerini öğrenirsin."}, spells = {"Stupefy", "Expelliarmus", "Reducto", "Flipendo"}},
        {xp = 250, rewards = {"Protego gibi koruma tılsımlarını seri şekilde kullanabilme özelliği edinirsin. Basit düzeydeki karanlık yaratıkları tanıyabilirsin. Ayrıca Rictusempra ve Solis büyüsünü öğrenirsin."}, spells = {"Rictusempra", "Solis"}},
        {xp = 350, rewards = {"Çevrende kurulmuş basit gizli lanetli tuzakları tespit edip bozabilirsin. Petrificus Totalus ve Impedimenta büyülerini kullanmayı öğrenirsin."}, spells = {"Petrificus Totalus", "Impedimenta"}},
        {xp = 500, rewards = {"Söz söylemeden büyü yapabilmeyi öğrenirsin ve Patronus üstünde ustalışırsın."}, spells = {"Expecto Patronum"}},
        {xp = 700, rewards = {"Orta ve ileri düzey lanetlerin etkilerini azaltabilirsin. Diğer büyücülere karanlık sanatlara karşı savunma hakkında başlangıç ve orta düzey bilgiler öğretebilirsin."}}
    }   
})

Reg("botanik", {
    name = "Botanik",
    desc = "",
    icon = "materials/botanik.png",
    color = Color(28, 161, 41, 211),
    levels = {
        {xp = 0, rewards = {"Temel botanik bilgisi edinirsin."}},
        {xp = 100, rewards = {"Mandragora gibi yaygın bitkilerin kulaklık takarak saksı değişimini ve sulamasını güvenle yapabilirsin. Isırgan otu, pelin otu ve papatya özü gibi basit bitkileri toplayabilirsin."}},
        {xp = 250, rewards = {"Boğmaca otu yetiştirebilir, şeytan tuzağı ile karşılaştığında lumen tılsımı ya da hafif ısı uygulayarak kurtulabilme yeteneği edinirsin. Ayrıca çeşitli ejderha gübrelerini kullanmayı öğrenip bitki büyütme hızlarını arttırabilirsin."}},
        {xp = 350, rewards = {"Mimbulus Mimbletonia bitkisinin Stinksap sıvısını elde edebilir ve kullanabilirsin. Tentaculum'un sarmaşık saldırılarına karşı Diffindo ile refleks geliştirip zarar görmeden yaklaşabilirsin. Karanlık ormanda bulunan bitkilerin tohumlarını elde edebilir ve yetiştirebilirsin."}},
        {xp = 500, rewards = {"Snargaluff odununu toplayıp özünü alıp iksir yapımında kullanabilirsin. Bakanlık veya okul yönetimi kontrolü altında Venöz Tentacula gibi tehlike bitkileri yetiştirebilir, ticari ya da akademik amaçla kullanabilirsin."}},
        {xp = 700, rewards = {"Serada asan ile istediğin iklim koşulunu ayarlayabilir ve bu iklimle uyumlu bitkileri yetiştirebilirsin. Yetiştirdiğin yarı-zihinsel bitkilere emir verebilirsin. Serada antik bitki yetiştirme izni alırsın."}}
    }
})

Reg("buyuculuk", {
    name = "Büyücülük",
    desc = "",
    icon = "materials/buyuculuk.png",
    color = Color(229, 15, 193, 181),
    levels = {
        {xp = 0, rewards = {"Temel büyücülük bilgisi edinirsin."}},
        {xp = 100, rewards = {"Asa tutuşun iyileşir ve hata payın azalır. Lumos büyüsünü istediğin zaman kullanıp kapatabilirsin ve Lumos büyüsü kazanırsın."}, spells = {"Lumos"}},
        {xp = 250, rewards = {"Wingardium Leviosa ve Accio büyüsnü öğrenir ve orta ağırlıkta nesneleri başarılı şekilde kaldırabilirsin. Temel seviye Protego büyüsü öğrenirsin, bu sayede basit büyüleri engelleyebilirsin. Reparo büyüsünü öğrenip küçük/orta hasarları onarabilirsin."}, spells = {"Wingardium Leviosa", "Protego", "Reparo"}},
        {xp = 350, rewards = {"Geniş bir odada asan ile ses yalıtımı, rüzgar ve ısı kontrolü yapabilirsin. Katı nesnelerinin cismini değiştirme temellerini öğrenir ve Transfiguration üstüne okumalar yaparsın."}},
        {xp = 500, rewards = {"Disillusionment Charm öğrenip çevrendeki dokuyu ve rengi abzorbe edip kamuflaj sağlayabilirsin. Karanlık ormanda cisimlenebilirsin."}},
        {xp = 700, rewards = {"Transfiguration üstünde ustalışırsın ve canlı olmayan büyük nesneleri karmaşık hayvan formlarına kalıcı olarak dönüştürebilme yeteneği edinirsin. Anti cisimlenme tılsımı olan yerlere cisimlenebilirsin. Odalarda ya da eşyalarda kalan zihir izlerini tespit edebilir, mühürleyip çözebilirsin."}},
    }
})

Reg("iksir", {
    name = "İksir",
    desc = "",
    icon = "materials/iksir.png",
    color = Color(25, 162, 208, 218),
    levels = {
        {xp = 0, rewards = {"Temel iksir bilgisi edinirsin."}},
        {xp = 100, rewards = {"Malzemeleri tam gramajında dövme ve sıvıları doğru sıcaklıkta karıştırma becerisi edinirsin. Çıban İksiri ve hafif Wiggenweld iksiri demleyebilirsin. Asitli ve dumanlı iksirlerde gerekli eşyaları doğru kullanıp patlama gibi hasar alınımı azaltırsın."}},
        {xp = 250, rewards = {"İksir demlerken ayarlanacak ısıyı tam doğru şekilde ayarlabilme yeteneği edinirsin. Polyjuice Potion için hazırlık aşamalarını ve Amortentia kokularını doğru analiz edebilme bilgisi kazanırsın. Saatin yönünde ve tersinde doğru dönüş sayılarıyla iksirin saflık derecesini artırma yeteneği edinirsin."}},
        {xp = 350, rewards = {"Veritaserum'un bazı ham maddelerini bozmadan mayalayabilir ve saklayabilirsin. Felix Felicis iksirinin temellerini bilirsin. Çeşitli standart zehirler için hızlı etki gösteren özel karşı-iksirler formüle edebilme yeteneği kazanırsın."}},
        {xp = 500, rewards = {"Wolfsbane iksirini kusursuz şekilde demlersin. Normalde uzun süren iksirleri özel tekniklerle süresini kısaltarak aynı kalitede daha hızlı iksir demleyebilirsin. Mevcut bildiğin iksirlere ekstra malzeme ya da farklı teknikler uygulayarak demleyip etkisini uzatabilirsin"}},
        {xp = 700, rewards = {"Felix Felicis iksirini başarı bir şekilde demleyebilirsin. Kendine ait iksirler demleyebilirsin. İksir buharı, patlayıcı iksir, asitli iksir demlerken kötü etkilerinden etkilenmezsin."}},
    }
})

Reg("lanet", {
    name = "Lanet",
    desc = "",
    npc = "curse",
    icon = "materials/lanet.png",
    levels ={
        {xp = 0, rewards = {"Temel lanet teorik bilgisini öğrenirsin."}},
        {xp = 100, rewards = {"Bat-Bogey Hex (Yarasa-Böcü) veya Densaugeo (Diş büyütme) gibi hafif cezalandırıcı büyüleri yapabilirsin. Karşı tarafın odaklanmasını dağıtabilecek küçük lanetler yapabilirsin. Nesnelere dokunulduğunda kişiyi irkiltecek lanetler uygulayabilirsin."}},
        {xp = 250, rewards = {"Langlock ve Impedimenta büyülerini öğrenip rakibin hareketini ya da konuşmasını kısıtlayabilirsin. Rakibe fiziksel acı verecek karanlık büyülerin pratiklerine başlarsın. Etkileşime girdiğin eşyalarda karanlık bir iz bırakırsın."}, spells = {"Langlock", "Impedimenta"}},
        {xp = 350, rewards = {"Yüzeysel kesikler açabilen tehlikeli bir kesme lanetini kontrollü ve düşük güçte deneyebilme. Hedefin zihnini karıştırarak yanlış kararlar almasını sağlayan güçlü bir kafa karışıklığı laneti öğrenirsin.  Küçük bir odayı veya koridoru girenler için soğuk ve korku yayan bir alan lanetiyle donatma yeteneği kazanırsın."}},
        {xp = 500, rewards = {"Temel düzeyde Imperius öğrenirsin, bu temel düzeyde kişinin iradesini kısa süreli baskı altına alıp komutlar verebilirsin. Ciddi yaralanmalara yol açabilecek tam güçte Sectumsempra lanetini isabetli atabilirsin. adece özel bir karşı büyüyle kalkabilecek inatçı lanetler inşa etme yetenği kazanırsın."}, spells = {"Sectumsempra"}},
        {xp = 700, rewards = {"Crucio öğrenirsin. Imperius büyüsünü tam kontrollü şekilde uygularsın. Avada Kedavra öğrenirsin. Hortluk hakkında teorik bilgi öğrenirsin"}, spells = {"Crucio", "Avada Kedavra"}}
    }
})

Reg("sifacilik", {
    name = "Şifacılık",
    desc = "",
    icon = "materials/lanet.png",
    levels = {
        {xp = 0, rewards = {"Teorik şifacılık bilgisi edinirsin."}},
        {xp = 100, rewards = {"Basit kesikleri, yanıkları ve sıyrıkları tıbbi malzemelerle tedavi edebilirsin. Kemik kaynatan iksirini hastaya doğru dozda uygulayabilirsin. Büyüsel ateşlenmeleri ve zehirlenme belirtilerini erken teşhis edebilirsin."}},
        {xp = 250, rewards = {"Rennervate tılsımını öğrenirsin. Kırık burunları, çıkık eklemleri ve orta düzey fiziksel travmaları büyü ile iyileştirebilirsin. Venöz Tentacula veya Boğmaca otu yaralanmalarına karşı özel merhemler hazırlamayı öğrenirsin."}, spells = {"Rennervate"}},
        {xp = 350, rewards = {"Hafif karanlık büyülerin ve hex'lerin etkilerini söküp atma yeteneği edinirsin. Yarım dönüşüm geçirmiş veya büyü kurbanı olmuş kişilerin dokularını stabilize edebilirsin.  Boggart korkusu veya hafif zihinsel tazyik altında kalmış kişilere sakinleştirici tılsımlar uygulayabilirsin."}},
        {xp = 500, rewards = {"Vulnera Sanentur öğrenirsin, bunun sayesinde derin kesik uygulayan büyüye maruz kalmış hastayı iyileştirebilirsin. Yanlış hafıza büyülerinden etkilenen hastayı başarılı şekilde iyileştirebilirsin. Aynı anda birden fazla yaralı büyücüye acil müdahale ederek triage sıralaması yapabilirsin."}, spells = {"Vulnera Sanentur"}},
        {xp = 700, rewards = {"Ölüm eşiğinde olan veya ağır lanetlere maruz kalan kişileri iyileştirebilirsin. Ejderha Çiçeği gibi tehlikeli ve bulaşıcı büyücü hastalıklarına karşı tedavi protokolü uygulayabilirsin. üyü dünyasının en karmaşık vakalarını çözme ve hastane yönetimi yetkisi kazanırsın."}}
    }
})

Reg("syb", {
    name = "Sihirli Yaratıkların Bakımı",
    desc = "",
    icon = "materials/syb.png",
    levels = {
        {xp = 0, rewards = {"Teorik syb bilgisi edinirsin."}},
        {xp = 100, rewards = {"Baykuş, kedi, kurbağa ve jumbo kuş gibi evcil/küçük hayvanların bakımını yapabilirsin. Parlak nesnelere düşkün Nifler'i güvenle yönlendirme ve ellerinden eşya geri alma teknikleri öğrenirsin. Ağaçlardaki Bowtruckle'ları ürkütmeden onlara böcek vererek güven kazanabilirsin."}},
        {xp = 250, rewards = {"Hipogrif yaklaşım kuralını (göz kesmeden eğilme) kusursuz uygulayıp sırtına binebilirsin. Zeki yaratıklar olan Kneazle'ları evcilleştirme ve tehlikeleri sezmelerini sağlama.  Küçük ve orta boy akromantulalara karşı Arania Exumai tılsımını etkili kullanabilme."}, spells = {"Arania Exumai"}},
        {xp = 350, rewards = {"Ölümü görmüş kişilerin görebileceği Testral'ları besleme, yönlendirme ve koşum takımı takabilme. Saf yaratıklar olan Unicorn'ların yaralarını sarma ve onlara güvenli yaşam alanı sağlama. Ejderha yumurtalarını doğru sıcaklıkta kuluçkaya yatırma ve ilk beslemelerini yapma."}},
        {xp = 500, rewards = {"Genç ejderhalarla güvenli mesafe kurarak besleme, taşıma ve temel komut verme yeteneği edinirsin.  Dolunay dışında insan formundaki kurtadamların ruh hali ve barınma ihtiyaçlarını yönetebilirsin. Çevrede beliren tehlikeli büyüsel yaratıkları zarar vermeden yakalayıp güvenli bölgeye taşıyabilirsin."}},
        {xp = 700, rewards = {": Tam boyutlu bir ejderhanın öfkesini yatıştırma ve özel durumlarda yönlendirme yetkisi.  Efsanevi anka kuşlarıyla bağ kurabilme, gözyaşlarının şifa gücünden yararlanabilme. Yasak Orman'daki tüm yaratık klanları (Atadamlar, Devler, Akromantulalar) ile diplomatik ilişki kurabilme."}}
    }
})

Reg("tilsim", {
    name = "Tılsım",
    desc = "",
    icon = "materials/tilsim.png",
    levels = {
        {xp = 0, rewards = {"Teorik basit tılsım bilgisi edinirsin."}},
        {xp = 100, rewards = {"Wingardium Leviosa ile tüyleri, paraları ve hafif kitapları havaya kaldırıp süzdürme. Sonorus ile ses tonunu ayarlama, temel aydınlatma tılsımlarını kusursuz yapma. Alohomora büyüsüyle basit kilitleri ve kapıları açabilme."}, spells = {"Wingardium Leviosa", "Sonorus", "Alohomora"}},
        {xp = 250, rewards = {"Accio ve Deprimo büyülerini öğrenip basit nesneler üstünde kullanabilirsin. Colorvaria büyüsünü kusursuz şekilde nesnelerde kullanabilirsin. Scourgify ile odaları ve masaları pırıl pırıl yapma, eşyaları otomatik raflama yapabilirsin."}, spells = {"Accio", "Deprimo", "Scourgify"}},
        {xp = 350, rewards = {"Colloportus ile kapıları büyüyle mühürleme, Immobulus ile hareketli nesneleri durdurabilirsin. Bulunduğu ortamda ses yankısı yaratma veya küçük nesneleri görünmez kılma. Kendi bedenini veya hafif bir nesneyi havaya kaldırıp kısa süreliğine uçurma."}, spells = {"Colloportus", "Immobulus"}},
        {xp = 500, rewards = {"Belirli bir odada yerçekimini tamamen sıfırlayarak eşyaların havada yüzmesini sağlama. Büyülü günlük eşyalar (otomatik karıştırılan kaşıklar, uçan kartpostallar) imal edebilme.  Geniş alanları koruyan koruyucu büyü alanları (bariyerler) örme."}, spells = {"Protego Totalum"}},
        {xp = 700, rewards = {"Hareketli merdivenler veya kaybolan odalar tarzı kalıcı ve karmaşık mimari tılsımlar inşa edebilme. Cansız heykellere veya nesnelere geçici bir bilinç ve hareket kabiliyeti kazandırma. Çadırların içine devasa odalar sığdıran Undetectable Extension Charm (Genişletme Tılsımı) ustalık seviyesine gelirsin."}, spells = {"Undetectable Extension Charm"}}
    }
})




-- Görevler (WIP)

--local function Quest(q)
    --ix.ven.kg.Quests[#ix.ven.kg.Quests + 1] = q
    --ix.ven.kg.QuestByID[q.id] = q
--end

--Quest({id = "d_book", period = "daily", name = "Günlük Kitap Okuma", desc = "1 kitap oku", type = "book", amount = 1, discipline = nil, reward = {xp = nil = 5}})
--Quest({id = "d_class", period = "daily", name = "Derse Katılım", desc = "1 derse katıl.", type = "class", amount = 1, discipline = nil, reward = {xp = nil = 10}})
--Quest({id = "d_ksks", period = "daily", name = "KSKS", desc = "Ksks'de 5 exp kazan.", type = "xp", amount = 1, discipline = "ksks", reward = {xp = {ksks = 5}}})

--Quest({id = "w_book", period = "weekly", name = "Haftalık Okuma", desc = "5 kitap oku.", type = "book", amount = 5, reward = {money = 150}})
--Quest({id = "w_class", period = "weekly", name = "Devamlı Öğrenci", desc = "4 derse katıl.", type = "class", amount = 4, reward = {money = 200}})
--Quest({id = "w_iksir", period = "weekly", name = "İksir Çırağı", desc = "İksir'de 100 XP kazan.", type = "xp", discipline = "iksir", amount = 100, reward = {xp = {iksir = 40}}})

--Quest({id = "m_book", period = "monthly", name = "Kitap Kurdu", desc = "20 kitap oku.", type = "book", amount = 20, reward = {money = 600}})
--Quest({id = "m_class", period = "monthly", name = "Örnek Öğrenci", desc = "15 derse katıl.", type = "class", amount = 15, reward = {money = 800}})
--Quest({id = "m_tilsim", period = "monthly", name = "Tılsım Uzmanı", desc = "Tılsım'da 400 XP kazan.", type = "xp", discipline = "tilsim", amount = 400, reward = {xp = {tilsim = 150}}})




--Diğer fonksyionlar
function ix.ven.kg.RollTier()
    local total = 0
    for _, t in ipairs(ix.ven.kg.BookTiers) do total = total + t.weight end 

    local r = math.random() * total
    for i, t in ipairs(ix.ven.kg.BookTiers) do
        r = r - t.weight
        if r <= 0 then return i end
    end
    return 1
end

function ix.ven.kg.RollDiscipline(npcKey)
    local total = 0
    local pool ={}
    for _, d in ipairs(ix.ven.kg.DisciplineList) do
        if (d.npc or "libary") == npcKey then
            local w = d.dropWeight or 1
            pool[#pool + 1] = {d = d, w = w}
            total = total + w
        end 
    end 

    local r = math.random() * total
    for _, e in ipairs(pool) do
        r = r - e.w
        if r <= 0 then return e.d.id end
    end
    return pool[1] and pool[1].d.id
end 

function ix.ven.kg.GetLevel(disc, xp)
    local d = ix.ven.kg.Disciplines[disc]
    local lvl = 1
    if not d then return 1 end
    for i, l in ipairs(d.levels) do
        if xp >= l.xp then lvl = i end
    end
    return lvl
end

function ix.ven.kg.GetMaxLevel(disc)
    local d = ix.ven.kg.Disciplines[disc]
    return d and #d.levels or 1
end

function ix.ven.kg.GetMaxXP(disc)
    local d = ix.ven.kg.Disciplines[disc]
    return d and d.levels[#d.levels].xp or 0
end

-- seviye ilerleme
function ix.ven.kg.GetProgress(disc, xp)
    local d = ix.ven.kg.Disciplines[disc]
    if not d then return 1, 0, nil end 
    local lvl = ix.ven.kg.GetLevel(disc, xp)
    local cur = d.levels[lvl].xp
    local nxt = d.levels[lvl + 1]
    return lvl, xp - cur, nxt and (nxt.xp - cur) or nil
end

function ix.ven.kg.FormatTime(sec)
    sec = math.floor(sec)
    return string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor(sec % 3600 / 60), sec % 60)
end

function ix.ven.kg.RewardText(r)
    local t = {}
    if not r then return "" end
    for disc, amt in pairs(r.xp or {}) do
        local d = ix.ven.kg.Disciplines[disc]
        t[#t + 1] = "+" .. amt .. " " .. (d and d.name or disc) .. " XP"
    end 
    if r.money then t[#t + 1] = ix.currency.Get(r.money) end
    for _, uid in ipairs(r.items or {}) do
        local it = ix.item.list[uid]
        t[#t + 1] = it and it.name or uid
    end
    return table.concat(t, ", ")
end 
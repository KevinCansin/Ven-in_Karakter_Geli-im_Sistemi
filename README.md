# Ven'in Karakter Gelişim Sistemi v0.1
  Eskiden geliştirip kenara attığım karakter gelişim sistemini açık kaynaklı olarak
 paylaşıyorum. Düzenleme, ekleme vb. şeyler yapacaksanız pull request atarsanız çok
 makbule geçer. Hataları vesaire olabilir ama düzeltmeye çok üşeniyorum.
  **Kullanılan FrameWork** = Helix (Garry's Mod)
  **Database türü** = MySQL / SQLite
  **Plugin Sürümü** = 0.1
  **Discord** = kevinjohnson.
  **Development ve Spell Design Server** = https://discord.gg/Xj3VzXhGsQ


 ---
 ## İçindekiler

 1. [Genel-Bakış](#1-genel-bakış)
 2. [Gereksinimler](#2-gereksinimler)
 3. [Kurulum](#3-ben-bunu-nasıl-kurucam)
 4. [Dosya-Yapısı-ve-Yükleme-Sırası](#4-dosya-yapısı-ve-yükleme-sırası)
 5. [Çalışma-Mantuğı](#5-çalışma-mantığı)
 6. [Oyuncu-İçin-Rehber](#6-oyuncu-için-rehber)
 7. [Yetkili-Rehberi-ve-Komutlar](#7-yetkili-rehberi-ve-komutlar)
 8. [Config-Referansı](#8-config-referansı-sh_config.lua)
 9. [Özelleştirme-Rehberi](#9-özelleştirme-rehberi)
 10. [Geliştirici-Referansı](#10-geliştirici-referansı)
 11. [Veritabanı](#11-veritabanı)
 12. [Mevcut-Karakter-Gelişimi-ve-Ödülleri](#12-mevcut-kgler)
 13. [Sorun-Giderme](#13-sorun-giderme)
 14. [Pluginde-Bilinen-Sınırlamalar](#14-bilinen-sınırlamalar)

---


## 1. Genel-Bakış

### Temel Kavramlar

**Yönelim (Discipline)** = Bir karakter gelişim dalı. Örnek olarak İksir, Botanik vs.
**Seviye (Level)** = Yönelimlerin seviyesi. Her seviyede IC yetkinlik ve büyü alırsın.
**Kitap (Book)** = Okununca KG xp'si verir. Her kitap bir yönelime ait.
**Kitap Seviyesi (Tier)** = Kitabın nadirliğini beliriler ve ona göre KG xp'si verir.
**NPC** = Kitap dağıtan karakter.
**Ders** = Flagi olan birinin yanındaki herkese kendi dersinden karakter gelişim xp'si vermesi.
**Görev** = Günlük/Haftalık/Aylık hedefler. (WIP)

### Özet Akış (çizdim tabikide)

```
                ┌──────────────┐
                │  KİTAP NPC'si │  (12 saatte bir)
                └──────┬───────┘
                       │ rastgele yönelim + rastgele kitap seviyesi
                       ▼
 ┌──────────┐    ┌────────────┐  Oku   ┌──────────────┐   seviye   ┌──────────────┐
 │  DERS    │──► │    XP      │ ◄───── │ KİTAP (item) │  atlayınca │ Ödül metinleri│
 │ (yetkili)│    │ (yönelim   │        └──────────────┘ ─────────► │ + Büyüler     │
 └──────────┘    │  bazlı)    │                                    └──────────────┘
 ┌──────────┐    └─────┬──────┘
 │ ADMİN XP │──────────┘
 └──────────┘          │
                       ▼
                 MySQL / SQLite
```

---


## 2. Gereksinimler

**Helix** = `ix.item`, `ix.command`, `ix.flag`, `ix.lang`, `ix.util`, `ix.type`, `mysql` API'leri kullanılır.
**Helix Veri Tabanı Bağlantısı** = İlk bağlantıda 3 tablo otomatik oluşturulur.
**HP Wand Rewrite** (`HpwRewrite`) = Büyü vermek için varsayılan olarak kullanılır. Kullanmıyorsan `Config.GiveSpell`'i değiştir
**Yönelim ikonları (.png)** = Yoksa renkli kutu + baş harf çizilir.

---

## 3. Kurulum

1. `ven_kgsistemi` klasörünü şemanın plugin dizinine koy:
   ```
   garrysmod/gamemodes/<şema_adı>/plugins/ven_kgsistemi/
   ```
2. (Opsiyonel) İkonları `garrysmod/materials/` altına koy. Bkz. [İkon yolları](#ikon-yolları).
3. Sunucuyu yeniden başlat. Konsolda Lua hatası çıkmadığını kontrol et.
4. Veritabanı bağlandığında `ix_ven_kg_progress`, `ix_ven_kg_quests`, `ix_ven_kg_cooldowns` tabloları otomatik oluşur.
5. Oyunda NPC'leri yerleştir (yetkili olarak):
   ```
   /VenKGNpcEkle libary
   /VenKGNpcEkle curse
   ```
6. Ders verecek kişilere flag ver (varsayılan `L`):
   ```
   /CharGiveFlag <karakter> L
   ```

> NPC'lerin konumu `PLUGIN:SaveData()` ile kaydedilir; sunucu/harita yeniden başlayınca `PLUGIN:LoadData()` ile aynı yerlerde geri gelir.

---

## 4. Dosya Yapısı ve Yükleme Sırası

```
ven_kgsistemi/
├── sh_plugin.lua                         # Giriş noktası
├── sh_config.lua                         # Config dosyası ve yardımcı fonksiyonlar
├── sh_commands.lua                       # Komutlar
├── sv_database.lua                       # Tablolar, kaydetme, yükleme
├── sv_plugin.lua                         # Sunucu mantığı
├── cl_plugin.lua                         # İstemci net alıcıları ve istemci verisi
├── cl_panels.lua                         # Arayüz panelleri
├── entities/entities/
│   ├── ix_ven_kg_kutuphaneci.lua         # Kütüphaneci NPC
│   └── ix_ven_kg_lanetsatan.lua          # Kötü Kütüphaneci NPC
└── items/
    ├── base/sh_kitap.lua                 # Kitap base item'ı (base_kitap)
    ├── sh_ven_kg_ksks.lua
    ├── sh_ven_kg_botanik.lua
    ├── sh_ven_kg_buyuculuk.lua
    ├── sh_ven_kg_iksir.lua
    ├── sh_ven_kg_lanet.lua
    ├── sh_ven_kg_sifacilik.lua
    ├── sh_ven_kg_syb.lua
    └── sh_ven_kg_tilsim.lua
```

### Yükleme Sırası (`sh_plugin.lua`)

| Sıra | Dosya | Realm | Ne yapar |
|---|---|---|---|
| 1 | `sh_plugin.lua` | Shared | `ix.ven`, `ix.ven.kg`, `ix.ven.gui` tablolarını oluşturur, dil metinlerini kaydeder |
| 2 | `sh_config.lua` | Shared | Config, kitap seviyeleri, NPC'ler, yönelimler, yardımcı fonksiyonlar |
| 3 | — | — | `ix.flag.Add(TeachFlag, "Ders verme yetkisi.")` |
| 4 | `sh_commands.lua` | Shared | Komutlar |
| 5 | `sv_database.lua` | Server | DB |
| 6 | `sv_plugin.lua` | Server | Sunucu mantığı |
| 7 | `cl_plugin.lua` | Client | Net alıcıları |
| 8 | `cl_panels.lua` | Client | Paneller |

> Dosya adı öneklerine (`sh_`, `sv_`, `cl_`) göre Helix, dosyayı doğru realm'de yükler.

### Dosya sorumlulukları

| Dosya | İçerdiği önemli şeyler |
|---|---|
| `sh_config.lua` | `Config`, `BookTiers`, `NPCs`, `Reg()`, `RollTier`, `RollDiscipline`, `GetLevel`, `GetMaxLevel`, `GetMaxXP`, `GetProgress`, `FormatTime`, `RewardText` |
| `sv_plugin.lua` | `AddXP`, `ReadBook`, `TeachClass`, `GiveSpell`, `ApplySpells`, `GrantLevelRewards`, `OpenNPC`, `NPCClaim`, `Sync`, görev fonksiyonları, `PlayerLoadedCharacter` / `PlayerSpawn` / `SaveData` / `LoadData` hook'ları |
| `sv_database.lua` | `DatabaseConnected` hook'u (tablolar), `SaveXP`, `SaveQuest`, `SaveCooldown`, `LoadCharacter`, `Str` |
| `cl_plugin.lua` | `ixvenKGSync` ve `ixvenKGOpenNPC` alıcıları, `GetClientXP` |
| `cl_panels.lua` | Sekmeler (Yönelimler, Ödüller, Görevler), NPC menüsü, ikon ve çizim yardımcıları |

---

## 5. Çalışma Mantığı

## 5.1 Karakter Yüklenme Akışı

```
PlayerLoadedCharacter
  └─► LoadCharacter(client, character)
        ├─ character.venkgData = {xp={}, quests={}, cooldowns={}, loaded=false}
        ├─ 3 asenkron SELECT (progress / quests / cooldowns)
        └─ üçü de bitince:
              loaded = true
              ApplySpells()   ← ulaşılmış tüm seviyelerin büyüleri tekrar verilir
              Sync()          ← istemciye veri gönderilir
```

Her işlem (`AddXP`, `ReadBook`, NPC...) önce `loaded` kontrolü yapar. Veri henüz yüklenmediyse oyuncuya "karakter verilerin yükleniyor" mesajı gelir.

### 5.2 XP ve seviye

- Seviye numarası, yönelimin `levels` listesindeki **sıra numarasıdır**. `levels[1]` her zaman `xp = 0` olmalıdır.
- `xp` değerleri **toplam** XP eşiğidir (seviye başına gereken değil).
- Bir yönelimin XP'si **son seviyenin XP'sini aşamaz**; fazlası kırpılır.
- XP zaten maksimumdaysa `AddXP` `false` döner ve hiçbir şey yapmaz.
- Birden fazla seviye aynı anda atlanırsa **atlanan her seviyenin ödülü sırayla** verilir.
- Seviye atlayınca:
  1. Ekran bildirimi gelir (`Notify`).
  2. Seviyenin `rewards` metinleri chat'e yazılır.
  3. Seviyenin `spells` listesi `GiveSpell` ile verilir ve chat'e yazılır.
  4. Görev ilerlemesi (`xp` tipi) güncellenir.
  5. DB'ye yazılır ve istemciye senkronize edilir.

### 5.3 Büyülerin kalıcılığı

Büyüler seviye atlarken verilir, ayrıca **karakter yüklenince** ve **her spawn'da (1 saniye gecikmeyle)** ulaşılmış bütün seviyelerin büyüleri tekrar verilir. Böylece büyü sistemi ölünce/yeniden doğunca büyüleri sıfırlasa bile oyuncu kaybetmez.

> Bu yüzden `GiveSpell` fonksiyonunun, aynı büyü ikinci kez verildiğinde sorun çıkarmaması gerekir.

### 5.4 Kitap okuma
`items/base/sh_kitap.lua` → "Oku" fonksiyonu → `ix.ven.kg.ReadBook(client, disc, tierID)`

Kontroller sırasıyla:

1. Karakter verisi yüklendi mi ve yönelim geçerli mi?
2. Yönelim zaten maksimum seviyede mi? → Reddeder, kitap silinmez.
3. `BookRequireLevel = true` ise ve yönelim seviyesi kitabın `reqLevel` değerinden düşükse → Reddeder, kitap silinmez.
4. Aksi halde: `kazanılan = floor(tier.xp × (bookXPMult veya 1))` kadar XP verilir, görev ilerlemesi (`book` tipi) eklenir, bildirim gösterilir.
5. `Config.ConsumeBook` değerini döner. `true` ise kitap envanterden silinir.

Kitap item'ı, seviyesini item verisinde (`tier`) saklar. Adı ve açıklaması buna göre dinamik oluşur:
- **Ad:** `<Yönelim Kitabı> (Seviye N)`
- **Açıklama:** yönelimin `bookDesc` metni + "Kitap seviyesi" + "Verdiği XP"

### 5.5 NPC'den kitap alma

```
NPC'ye E ► Use()  (1 sn spam koruması)
  └─► OpenNPC → istemciye: NPC entity'si, NPC anahtarı, kalan cooldown
        └─► NPC menüsü açılır (kitap havuzu, tier şansları, cooldown sayacı)

"Kitapları Al" ► ixvenKGNPCClaim
  └─► sunucu kontrolleri:
        • entity geçerli mi?
        • oyuncu NPCUseDistance içinde mi?
        • cooldown bitti mi?
  └─► bookCount kez:
        RollDiscipline(npc)  → NPC'nin havuzundan ağırlıklı yönelim
        RollTier()           → ağırlıklı kitap seviyesi
        envantere "ven_kg_<yönelim>" item'ı eklenir (tier verisiyle)
  └─► en az 1 kitap verildiyse cooldown başlar ve kaydedilir
```

- Envanter dolarsa kalan kitaplar verilmez; **o ana kadar verilenler için** cooldown yine başlar.
- Hiç kitap verilemediyse cooldown başlamaz.
- Cooldown **gerçek zamanla** (`os.time()`) ölçülür ve DB'de saklanır, sunucu restartında sıfırlanmaz.
- Cooldown **karakter + NPC** bazındadır. Aynı karakter iki farklı NPC'den ayrı ayrı alabilir.

### 5.6 NPC → yönelim eşleşmesi

Bir NPC'nin hangi yönelimlerin kitabını verdiği yönelimin `npc` alanıyla belirlenir:

| Yönelimin `npc` alanı | Kitabı kim verir? |
|---|---|
| (yazılmamış) | `libary` (Kütüphaneci) |
| `"libary"` | Kütüphaneci |
| `"curse"` | Kötü Kütüphaneci |

Varsayılanda `lanet` yönelimi `npc = "curse"` olduğu için yalnızca Kötü Kütüphaneci'den çıkar. Diğer 7 yönelim Kütüphaneci'nin havuzundadır.

### 5.7 Ders sistemi

`/VenKGDers <yönelim> [xp]` → `TeachClass(öğretmen, yönelim, xp)`

- `ClassRadius` içindeki, karakteri olan **herkese** (öğretmen hariç) XP verir.
- XP yazılmazsa `Config.ClassXP` kullanılır.
- Her öğrenci için `class` tipi görev ilerlemesi eklenir ve bildirim gönderilir.
- Komutu kullanabilenler: **adminler** veya karakterinde `TeachFlag` (varsayılan `L`) flag'i olanlar.

### 5.8 Görevler (WIP)

Altyapı hazır ama görev tanımları şu an `sh_config.lua` içinde **yorum satırında**. Aktif edilmediği sürece Görevler sekmesi boş görünür. Detay için bkz. [Görev ekleme](#görev-sistemini-açmak-ve-görev-eklemek).

- Dönemler: `daily` (günlük, `YYYY-MM-DD`), `weekly` (haftalık, `YYYY-Whafta`), `monthly` (aylık, `YYYY-MM`). Sunucu saatine göre.
- Dönem anahtarı değişince görev ilerlemesi otomatik sıfırlanır.
- Görev tamamlanınca "ödülünü al" bildirimi gelir; ödül menüden alınır (`ixvenKGQuestClaim`).
- Ödül türleri: XP (yönelim bazlı), para, item.

---

## 6. Oyuncu Rehberi

### Karakter Gelişimi menüsü

F1 menüsünde **"Karakter Gelişimi"** sekmesi bulunur ve 3 alt sekmeye ayrılır:

| Sekme | Ne gösterir? |
|---|---|
| **Karakter Gelişimi** | Her yönelimin kartı: ikon, ad, seviye (X / 6), XP barı |
| **Ödüller** | Sol listeden yönelim seç → o yönelimin tüm seviyeleri, XP eşikleri, ödül metinleri ve büyüler. Ulaşılan seviyeler renkli ve **Açıldı**, ulaşılmayanlar soluk ve **Kilitli** görünür |
| **Görevler** | Günlük / haftalık / aylık görevler (WIP) |

### Kitap almak

1. Kütüphaneci NPC'sine yaklaş ve **E** tuşuyla etkileşime gir.
2. Açılan pencerede kitap havuzunu ve seviye şanslarını görürsün.
3. **Kitapları Al** butonuna bas. Bekleme süresi doluysa kitaplar envanterine gelir.
4. Envanterde kitaba sağ tık → **Oku**.

> Kötü Kütüphaneci'den yalnızca **Lanet** kitabı çıkar.

---

## 7. Yetkili Rehberi ve Komutlar

| Komut | Yetki | Argümanlar | Açıklama |
|---|---|---|---|
| `/VenKGNpcEkle` | Admin | `<libary \| curse>` | Baktığın noktaya NPC koyar. NPC sana dönük spawn olur ve konumu kaydedilir |
| `/VenKGNpcSil` | Admin | — | Baktığın NPC'yi siler ve kaydeder |
| `/VenKGXpVer` | Admin | `<karakter> <yönelim_id> <miktar>` | Karaktere XP verir (miktar 0'a yuvarlanır, negatif verilmez) |
| `/VenKGDers` | Admin veya `TeachFlag` | `<yönelim_id> [xp]` | `ClassRadius` içindeki herkese XP verir |

**Yönelim ID'leri:** `ksks`, `botanik`, `buyuculuk`, `iksir`, `lanet`, `sifacilik`, `syb`, `tilsim`

**Örnekler**
```
/VenKGNpcEkle libary
/VenKGXpVer "Ahmet Yılmaz" iksir 100
/VenKGDers botanik            → varsayılan ClassXP (40)
/VenKGDers botanik 75         → 75 XP
```

**Item verme (test için):**
```
/CharGiveItem <karakter> ven_kg_botanik
```
Item ID'leri `ven_kg_<yönelim_id>` şeklindedir. Bu şekilde verilen kitap **Seviye 1** (`tier` verisi yoksa varsayılan 1) olur.

**NPC'leri spawn menüsünden** de çıkarabilirsin ("Ven'in Karakter Gelişimi" kategorisi). Ancak kalıcı kaydedilmesi için `/VenKGNpcEkle` komutunu kullan.

---

## 8. Config Referansı (`sh_config.lua`)

Bütün ayarlar bu dosyadadır.

### 8.1 `ix.ven.kg.Config`

```lua
ix.ven.kg.Config = {
    BookRequireLevel = false,
    ClassXP          = 40,
    ClassRadius      = 300,
    ConsumeBook      = true,
    NPCUseDistance   = 100,
    TeachFlag        = "L",
    GiveSpell        = function(client, spell) HpwRewrite:LearnSpell(client, spell) end,
    Theme            = { ... }
}
```

| Anahtar | Tip | Varsayılan | Açıklama |
|---|---|---|---|
| `BookRequireLevel` | bool | `false` | `true` ise kitabı okumak için yönelim seviyesi kitabın `reqLevel` değerine eşit/yüksek olmalı |
| `ClassXP` | sayı | `40` | `/VenKGDers` XP yazılmadan kullanılırsa verilecek XP |
| `ClassRadius` | sayı | `300` | Dersin etki yarıçapı (Source birimi) |
| `ConsumeBook` | bool | `true` | Okunan kitap silinsin mi? |
| `NPCUseDistance` | sayı | `100` | "Kitapları Al" için NPC'ye maksimum uzaklık (sunucu tarafında doğrulanır) |
| `TeachFlag` | string | `"L"` | Ders verme yetkisi flag'i (tek harf) |
| `GiveSpell` | function | HpwRewrite | `(client, spell)` alır. Büyü verme yöntemi |

### 8.2 `Theme`

| Anahtar | Kullanıldığı yer |
|---|---|
| `bg` | NPC menüsü arka planı |
| `card` | Kart ve satır arka planları |
| `accent` | Vurgu rengi, başlıklar, aktif sekme |
| `text` | Ana yazı |
| `muted` | Soluk yazı (kilitli seviyeler, açıklamalar) |
| `good` | Olumlu durum ("Açıldı", tamamlanan görev) |
| `bad` | Olumsuz durum ("Kilitli") |

### 8.3 `ix.ven.kg.BookTiers`

| # | Ad | XP | Ağırlık | Yaklaşık şans | `reqLevel` |
|---|---|---|---|---|---|
| 1 | Seviye 1 | 5 | 50 | %50 | 1 |
| 2 | Seviye 2 | 10 | 30 | %30 | 1 |
| 3 | Seviye 3 | 15 | 14 | %14 | 2 |
| 4 | Seviye 4 | 30 | 5 | %5 | 3 |
| 5 | Seviye 5 | 40 | 1 | %1 | 4 |

| Alan | Açıklama |
|---|---|
| `name` | Kitap adında ve bildirimlerde görünür |
| `xp` | Okuyunca verilen temel XP |
| `weight` | Düşme ağırlığı. Şans = `weight ÷ toplam weight` |
| `reqLevel` | Sadece `BookRequireLevel = true` iken kullanılır |

>  Item `tier` verisini **liste sırası (index)** olarak saklar. Mevcut bir tier'ı silmek veya araya yeni tier sokmak, oyuncuların envanterindeki eski kitapların seviyesini kaydırır. Yeni tier'ları **her zaman sona ekle**.

### 8.4 `ix.ven.kg.NPCs`

| Alan | Açıklama |
|---|---|
| anahtar (`libary`, `curse`) | NPC kimliği. Komutta ve yönelimlerin `npc` alanında kullanılır |
| `name` | Menüde ve NPC üstünde görünen ad |
| `desc` | Açıklama metni |
| `model` | Config'de tanımlı ama **şu an entity dosyalarında kullanılmıyor** (bkz. [NPC modeli](#npc-modelini-değiştirmek)) |
| `class` | Entity sınıf adı. **Entity dosya adıyla birebir aynı olmalı** |
| `bookCount` | Tek seferde verilen kitap sayısı |
| `cooldown` | Tekrar alma süresi, **saniye** |

Varsayılan değerler:

| NPC | Kitap sayısı | Cooldown | Havuz |
|---|---|---|---|
| `libary` | 3 | 12 saat | 7 yönelim (lanet hariç) |
| `curse` | 1 | 12 saat | Sadece `lanet` |

### 8.5 Yönelim alanları (`Reg(id, data)`)

| Alan | Zorunlu | Açıklama |
|---|---|---|
| `name` | evet | Görünen ad |
| `levels` | evet | Seviye listesi |
| `desc` | hayır | Yönelim kartında ve NPC menüsündeki kitap satırında görünür |
| `icon` | hayır | İkon yolu. Yoksa renkli kutu + baş harf çizilir |
| `color` | hayır | XP barı ve Ödüller sekmesi vurgusu. Yoksa `Theme.accent` |
| `npc` | hayır | Kitabı veren NPC anahtarı (varsayılan `"libary"`) |
| `dropWeight` | hayır | NPC havuzundaki çıkma ağırlığı (varsayılan `1`) |
| `bookName` | hayır | Kitap adı (varsayılan `"<name> Kitabı"`) |
| `bookDesc` | hayır | Kitap açıklaması |
| `bookXPMult` | hayır | Kitap XP çarpanı (varsayılan `1`) |

### 8.6 Seviye alanları

| Alan | Açıklama |
|---|---|
| `xp` | Bu seviyeye ulaşmak için gereken **toplam** XP (artan sırada) |
| `rewards` | Metin listesi (`{"...", "..."}`). Ödüller sekmesinde gösterilir ve seviye atlayınca chat'e yazılır |
| `spells` | Büyü adı listesi. **`rewards`'ın içinde değil, yanında** olmalı |

Doğru yazım:

```lua
{xp = 250,
 rewards = {"Protego öğrenirsin."},
 spells  = {"Protego"}},
```

### 8.7 Mevcut XP eşikleri

Bütün yönelimlerde aynıdır:

| Seviye | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| **Toplam XP** | 0 | 100 | 250 | 350 | 500 | 700 |

---

## 9. Özelleştirme Rehberi

### Yeni yönelim eklemek

Örnek: **Simya**

**1) `sh_config.lua`** — mevcut `Reg(...)` çağrılarının yanına ekle:

```lua
Reg("simya", {
    name     = "Simya",
    desc     = "Maddelerin dönüşümü üzerine.",
    color    = Color(180, 120, 40, 220),
    bookName = "Simya Ders Kitabı",
    levels = {
        {xp = 0,   rewards = {"Temel simya bilgisi edinirsin."}},
        {xp = 100, rewards = {"Basit dönüşümleri yapabilirsin."}},
        {xp = 250, rewards = {"Orta düzey dönüşümleri öğrenirsin."}, spells = {"Simya Büyüsü"}},
    }
})
```

**2) `items/sh_ven_kg_simya.lua`** — yeni dosya:

```lua
ITEM.name = "Simya Ders Kitabı"
ITEM.base = "base_kitap"
ITEM.venKGDiscipline = "simya"     -- Reg'deki id ile birebir aynı
```

**3)** Sunucuyu yeniden başlat. Yönelim; menüde, Kütüphaneci'nin havuzunda ve komutlarda (`/VenKGXpVer ... simya ...`) otomatik görünür.

> **Kural:** Item dosya adı `sh_ven_kg_<id>.lua` olmalı. Çünkü sunucu kitabı `"ven_kg_" .. <id>` adıyla envantere ekler.

### Seviye eklemek veya XP eşiklerini değiştirmek

Yönelimin `levels` listesine satır ekle veya `xp` değerlerini değiştir. Eşikler artan sırada kalmalı. Maksimum XP, son satırın `xp` değerine otomatik uyar. Eşikleri değiştirmek oyuncuların kayıtlı XP'sini değiştirmez, sadece hangi seviyede sayılacaklarını etkiler.

### Kitap seviyelerini ve şanslarını ayarlamak

```lua
-- Sona yeni seviye ekle
{name = "Seviye 6", xp = 75, weight = 1, reqLevel = 5},
```

Şansı değiştirmek için `weight` değerleriyle oyna. Toplamın 100 olması gerekmez.

### Bir yönelimi daha sık ya da nadir çıkarmak

```lua
Reg("iksir", { ..., dropWeight = 3 })      -- diğerlerinin 3 katı sıklıkta
Reg("tilsim", { ..., dropWeight = 0.5 })   -- yarı sıklıkta
```

### Bir yönelimi başka NPC'ye bağlamak

```lua
Reg("lanet", { ..., npc = "curse" })
```

### Yönelim bazlı kitap XP çarpanı

```lua
Reg("tilsim", { ..., bookXPMult = 1.5 })   -- bu yönelimin kitapları %50 fazla XP verir
```

### Yeni NPC eklemek

Örnek: **Şifacı Kütüphaneci** (`healer`)

**1)** `entities/entities/ix_ven_kg_sifaci.lua` oluştur (mevcut bir NPC dosyasını kopyala) ve şunları değiştir:

```lua
ENT.PrintName = "Şifacı Kütüphaneci"
ENT.venKGNPC  = "healer"
```

**2)** `NPCs` tablosuna ekle:

```lua
healer = {
    name      = "Şifacı Kütüphaneci",
    desc      = "Şifacılık kitapları verir.",
    model     = "models/humans/group01/female_02.mdl",
    class     = "ix_ven_kg_sifaci",      -- dosya adıyla aynı
    bookCount = 2,
    cooldown  = 6 * 60 * 60
},
```

**3)** Kitaplarını bağla:

```lua
Reg("sifacilik", { ..., npc = "healer" })
```

**4)** Oyunda `/VenKGNpcEkle healer`

> Komutun hata mesajındaki "Npcler: libary, curse" metni sabittir. Yeni NPC eklersen `sh_commands.lua` içindeki bu metni de güncelle.

### NPC modelini değiştirmek

Model, entity dosyasında sabit yazılı:

```lua
self:SetModel("models/humans/group01/male_02.mdl")
```

Doğrudan oradan değiştirebilirsin. Config'deki `model` alanından okunması için `Initialize` içinde şu şekilde değiştir:

```lua
local cfg = ix.ven.kg.NPCs[self.venKGNPC]
self:SetModel(cfg and cfg.model or "models/humans/group01/male_02.mdl")
```

### Cooldown süresi

NPC'nin `cooldown` değerini saniye olarak değiştir: `30 * 60` = 30 dk, `24 * 60 * 60` = 24 saat.

### Büyü sistemini değiştirmek

```lua
GiveSpell = function(client, spell)
    local char = client:GetCharacter()
    char:GiveSpell(spell)         -- kendi sisteminin çağrısı
end,
```

Bu fonksiyon seviye atlarken, karakter yüklenirken ve her spawn'da çağrılır. Tekrar çağrılmaya dayanıklı olmalı.

### Ders yetkisini başka flag'e taşımak

```lua
TeachFlag = "T",
```

`sh_plugin.lua` bu harfi `ix.flag.Add` ile otomatik kaydeder. Helix'in veya başka pluginlerin kullandığı harflerle çakışmayan bir harf seç. Mevcut öğretmenlere yeni flag'i yeniden vermen gerekir.

### Metinleri değiştirmek

| Metin | Konum |
|---|---|
| Menü sekmesi adı | `sh_plugin.lua` → `ix.lang.AddTable` |
| Bildirimler ve chat mesajları | `sv_plugin.lua` içindeki `Notify` / `ChatPrint` çağrıları |
| NPC menüsü metinleri | `cl_panels.lua` → `NPC:Setup` ve `NPC:Paint` |
| Alt sekme adları | `cl_panels.lua` → `TABS` |
| Ödül ve yönelim metinleri | `sh_config.lua` → `Reg(...)` |

### Arayüz renklerini değiştirmek

Genel renkler için `Config.Theme`, yönelime özel vurgu rengi için `Reg` içindeki `color` alanı.

### İkon yolları

`icon` değeri `garrysmod/materials/` klasörüne **göre** yazılır:

| Dosya | `icon` değeri |
|---|---|
| `garrysmod/materials/ksks.png` | `"ksks.png"` |
| `garrysmod/materials/diestra/ksks.png` | `"diestra/ksks.png"` |

İkon bulunamazsa hata vermez, yerine yönelimin `color` rengiyle bir kutu ve adının ilk harfi çizilir. Sunucudan istemciye aktarım için `resource.AddFile` kullanılır (ya da workshop / FastDL).

### Arayüze yeni sekme eklemek

`cl_panels.lua` içindeki `TABS` tablosuna `{"Sekme Adı", "panelAdı"}` ekle ve paneli kaydet:

```lua
local MYTAB = {}
function MYTAB:Init() ... end
vgui.Register("benimPanelim", MYTAB, "EditablePanel")
```

### Görev sistemini açmak ve görev eklemek

`sh_config.lua` içindeki "Görevler (WIP)" bölümünde yorum satırında bırakılan `Quest()` yardımcısını aç:

```lua
local function Quest(q)
    ix.ven.kg.Quests[#ix.ven.kg.Quests + 1] = q
    ix.ven.kg.QuestByID[q.id] = q
end

Quest({
    id = "d_book", period = "daily", name = "Günlük Kitap Okuma",
    desc = "1 kitap oku.", type = "book", amount = 1,
    reward = {xp = {buyuculuk = 5}}
})

Quest({
    id = "w_iksir", period = "weekly", name = "İksir Çırağı",
    desc = "İksir'de 100 XP kazan.", type = "xp", discipline = "iksir", amount = 100,
    reward = {xp = {iksir = 40}, money = 150}
})
```

| Alan | Açıklama |
|---|---|
| `id` | Benzersiz kimlik (DB'de saklanır, sonradan değiştirme) |
| `period` | `"daily"` · `"weekly"` · `"monthly"` |
| `name`, `desc` | Arayüzde görünen metinler |
| `type` | `"book"` (kitap oku) · `"class"` (derse katıl) · `"xp"` (XP kazan) |
| `amount` | Hedef miktar |
| `discipline` | Opsiyonel. Verilirse sadece o yönelimdeki ilerleme sayılır |
| `reward.xp` | `{yönelim_id = miktar}` |
| `reward.money` | Para miktarı |
| `reward.items` | Item uniqueID listesi |

> `xp` tipinde `amount`, kazanılan XP toplamını ifade eder. Yazılan örnek yorumları kullanırken `xp = nil = 5` gibi geçersiz yazımları düzelt.

---

## 10. Geliştirici Referansı

Bütün fonksiyonlar `ix.ven.kg` altındadır.

### Sunucu (`sv_plugin.lua`, `sv_database.lua`)

| Fonksiyon | Açıklama |
|---|---|
| `AddXP(client, disc, amount)` | XP ekler, seviye ödüllerini verir, DB'ye yazar, senkronize eder. XP eklendiyse `true` döner |
| `ReadBook(client, disc, tierID)` | Kitap okuma mantığı. Kitap silinsin mi → `true/false` |
| `TeachClass(teacher, disc, xp)` | Yakındakilere XP verir, sayıyı döner |
| `GiveSpell(client, spell)` | `Config.GiveSpell`'i çağırır |
| `ApplySpells(client, character)` | Ulaşılmış tüm seviyelerin büyülerini yeniden verir |
| `GrantLevelRewards(client, disc, level)` | Tek seviyenin ödüllerini verir |
| `OpenNPC(client, ent)` | NPC menüsünü açtırır |
| `NPCClaim(client, npcKey)` | Cooldown kontrolü + kitap dağıtımı |
| `GetCooldownRemaining(char, npcKey)` | Kalan saniye |
| `AddQuestProgress(client, type, disc, amount)` | Görev ilerletir |
| `GetQuestState(char, quest)` | Görevin güncel durumunu döner (dönem değiştiyse sıfırlar) |
| `ClaimQuest(client, questID)` | Görev ödülünü verir |
| `PeriodKey(period)` | Dönem anahtarını üretir |
| `Sync(client)` | İstemciye `{xp, cooldowns, quests}` yollar |
| `LoadCharacter(client, character)` | DB'den yükler |
| `SaveXP(charID, disc, xp)` | XP yazar |
| `SaveQuest(charID, id, state)` | Görev durumu yazar |
| `SaveCooldown(charID, npc, time)` | Cooldown yazar |
| `Str(s)` | SQL için kaçışlı string üretir |

### Paylaşılan (`sh_config.lua`)

| Fonksiyon | Açıklama |
|---|---|
| `RollTier()` | Ağırlıklı kitap seviyesi indeksi |
| `RollDiscipline(npcKey)` | NPC havuzundan ağırlıklı yönelim id'si |
| `GetLevel(disc, xp)` | XP'den seviye |
| `GetMaxLevel(disc)` | Maksimum seviye |
| `GetMaxXP(disc)` | Maksimum XP |
| `GetProgress(disc, xp)` | `seviye, seviye_içi_xp, sonraki_için_gereken_xp` (maksimumda üçüncüsü `nil`) |
| `FormatTime(sec)` | `SS:DD:ss` |
| `RewardText(reward)` | Görev ödülünü okunabilir metne çevirir |

### İstemci (`cl_plugin.lua`, `cl_panels.lua`)

| Öğe | Açıklama |
|---|---|
| `GetClientXP(disc)` | İstemcideki XP |
| `GetMaterial(path)` | Önbellekli material |
| `ClientData` | `{xp, quests, cooldowns, loaded}` |
| `ix.ven.gui.kgMain` | Açık ana panel |
| `ix.ven.gui.kgNPC` | Açık NPC paneli |

### Hook'lar

| Hook | Ne yapar |
|---|---|
| `DatabaseConnected` | Tabloları oluşturur |
| `PlayerLoadedCharacter` | Karakter verisini yükler |
| `PlayerSpawn` | 1 sn sonra büyüleri yeniden verir |
| `SaveData` / `LoadData` | NPC konumlarını kaydeder / geri yükler |
| `CreateMenuButtons` | F1 menüsüne sekmeyi ekler |

### Net mesajları

| Mesaj | Yön | İçerik |
|---|---|---|
| `ixvenKGSync` | S → C | `{xp, cooldowns, quests}` |
| `ixvenKGRequest` | C → S | Senkronizasyon isteği |
| `ixvenKGOpenNPC` | S → C | NPC entity'si, NPC anahtarı, kalan cooldown (UInt32) |
| `ixvenKGNPCClaim` | C → S | NPC entity'si |
| `ixvenKGQuestClaim` | C → S | Görev id'si |

### Kendi plugininden kullanım

```lua
-- XP ver
ix.ven.kg.AddXP(client, "iksir", 25)

-- Seviye kontrolü
local char = client:GetCharacter()
local data = char and char.venkgData
if data and data.loaded then
    local lvl = ix.ven.kg.GetLevel("botanik", data.xp["botanik"] or 0)
    if lvl >= 3 then
        -- Botanik 3 ve üstü
    end
end
```

### Item yapısı

`items/base/sh_kitap.lua` (`base_kitap`):

| Alan / Fonksiyon | Açıklama |
|---|---|
| `ITEM.venKGDiscipline` | Kitabın yönelimi. Alt item'larda tanımlanır |
| `ITEM:GetTier()` | `tierID, tierTablosu` döner (veri yoksa 1) |
| `ITEM:GetName()` | Dinamik ad |
| `ITEM:GetDescription()` | Dinamik açıklama + verdiği XP |
| `ITEM.functions.Read` | "Oku" fonksiyonu. Sadece envanterde iken çalışır (yerdeyken devre dışı) |

---

## 11. Veritabanı

| Tablo | Sütunlar | Anahtar |
|---|---|---|
| `ix_ven_kg_progress` | `char_id` INT, `discipline` VARCHAR(32), `xp` INT | (`char_id`, `discipline`) |
| `ix_ven_kg_quests` | `char_id` INT, `quest_id` VARCHAR(48), `period_key` VARCHAR(16), `progress` INT, `done` INT, `claimed` INT | (`char_id`, `quest_id`) |
| `ix_ven_kg_cooldowns` | `char_id` INT, `npc` VARCHAR(32), `last_take` BIGINT (unix zamanı) | (`char_id`, `npc`) |

Yazmalar `REPLACE INTO` ile yapılır (varsa üzerine yazar).

**Yararlı sorgular**
```sql
-- Bir karakterin bütün XP'sini gör
SELECT * FROM ix_ven_kg_progress WHERE char_id = <ID>;

-- XP'yi sıfırla
DELETE FROM ix_ven_kg_progress WHERE char_id = <ID>;

-- Kitap bekleme süresini sıfırla
DELETE FROM ix_ven_kg_cooldowns WHERE char_id = <ID>;
```

> Veri değişikliği yaptıktan sonra oyuncunun karakteri yeniden seçmesi (karakter yüklemesi) gerekir; yoksa bellekteki eski veri kullanılır.

---

## 12. Mevcut Karakter Gelişimi ve Ödülleri

| ID | Ad | Renk | Kitap item'ı | Kitabı veren NPC |
|---|---|---|---|---|
| `ksks` | Karanlık Sanatlara Karşı Savunma | koyu gri | `ven_kg_ksks` | Kütüphaneci |
| `botanik` | Botanik | yeşil | `ven_kg_botanik` | Kütüphaneci |
| `buyuculuk` | Büyücülük | pembe | `ven_kg_buyuculuk` | Kütüphaneci |
| `iksir` | İksir | mavi | `ven_kg_iksir` | Kütüphaneci |
| `lanet` | Lanet | (varsayılan vurgu) | `ven_kg_lanet` | **Kötü Kütüphaneci** |
| `sifacilik` | Şifacılık | (varsayılan vurgu) | `ven_kg_sifacilik` | Kütüphaneci |
| `syb` | Sihirli Yaratıkların Bakımı | (varsayılan vurgu) | `ven_kg_syb` | Kütüphaneci |
| `tilsim` | Tılsım | (varsayılan vurgu) | `ven_kg_tilsim` | Kütüphaneci |

### Seviyelerle verilen büyüler

| Yönelim | Seviye | Büyüler |
|---|---|---|
| KSKS | 2 | Stupefy, Expelliarmus, Reducto, Flipendo |
| KSKS | 3 | Rictusempra, Solis |
| KSKS | 4 | Petrificus Totalus, Impedimenta |
| KSKS | 5 | Expecto Patronum |
| Büyücülük | 2 | Lumos |
| Büyücülük | 3 | Wingardium Leviosa, Protego, Reparo |
| Lanet | 3 | Langlock, Impedimenta |
| Lanet | 5 | Sectumsempra |
| Lanet | 6 | Crucio, Avada Kedavra |
| Şifacılık | 3 | Rennervate |
| Şifacılık | 5 | Vulnera Sanentur |
| SYB | 3 | Arania Exumai |
| Tılsım | 2 | Wingardium Leviosa, Sonorus, Alohomora |
| Tılsım | 3 | Accio, Deprimo, Scourgify |
| Tılsım | 4 | Colloportus, Immobulus |
| Tılsım | 5 | Protego Totalum |
| Tılsım | 6 | Undetectable Extension Charm |

Botanik ve İksir'de büyü yoktur; sadece yazılı ödüller verilir. Büyü adları, kullanılan büyü sisteminde birebir aynı adla kayıtlı olmalıdır.

---

## 13. Sorun Giderme

| Belirti | Olası neden | Çözüm |
|---|---|---|
| Sunucu açılışında Lua hatası | Düzenleme sırasında sözdizimi hatası | Hata mesajındaki dosya ve satırı kontrol et. Virgül, `end`, tırnak eksikliği en sık sebepler |
| F1 menüsünde sekme yok | `cl_panels.lua` yüklenmemiş | İstemci konsolunu kontrol et |
| "Karakter verilerin yükleniyor" mesajı | Karakter verisi henüz DB'den gelmedi | Birkaç saniye bekle. Sürerse DB bağlantısını ve tabloları kontrol et |
| Tablolar oluşmadı | DB bağlantısı yok veya `DatabaseConnected` çalışmadı | Helix DB ayarlarını ve konsol hatalarını kontrol et |
| NPC spawn olmuyor / `Geçersiz NPC` | Yanlış anahtar | Sadece `libary` veya `curse` kullan |
| NPC spawn olmuyor (hata yok) | `class` ile entity dosya adı uyuşmuyor | `NPCs.<anahtar>.class` değeri dosya adıyla birebir aynı olmalı (ör. `ix_ven_kg_kutuphaneci`) |
| NPC haritayı yenileyince kayboluyor | Konum kaydedilmemiş | NPC'yi `/VenKGNpcEkle` ile ekle (spawn menüsünden eklenen kaydedilmez) |
| "Kitapları Al" çalışmıyor | NPC'den çok uzaksın veya cooldown dolmamış | `NPCUseDistance` içinde ol |
| Envantere kitap gelmiyor | Envanter dolu veya item bulunamadı | Envanterde yer aç. Item dosya adı `sh_ven_kg_<id>.lua` olmalı |
| Yeni yönelimin kitabı çıkmıyor | `npc` alanı farklı veya item dosyası yok | `npc` alanını ve item dosyasını kontrol et |
| XP geliyor ama seviye atlamıyor | `levels` XP eşikleri hatalı | `xp` değerleri artan sırada olmalı, ilk seviye `xp = 0` |
| Büyü verilmiyor | `HpwRewrite` yok veya fonksiyon adı farklı | Aşağıdaki not |
| Büyü adı geçerli değil | Büyü sistemindeki ad farklı | Büyü adını sistemdeki adla birebir eşle (büyük/küçük harf, boşluk) |
| `/VenKGDers` yetki hatası | Flag yok | `/CharGiveFlag <karakter> L` |
| Derste kimse XP almadı | Yarıçap dışı veya karakteri yok | `ClassRadius` değerini ve mesafeyi kontrol et |
| İkonlar görünmüyor | Yol hatalı veya dosya istemcide yok | [İkon yolları](#ikon-yolları). Yedek olarak renkli kutu çizilir |
| Görevler sekmesi boş | Görevler kapalı (WIP) | [Görev sistemini açmak](#görev-sistemini-açmak-ve-görev-eklemek) |
| Oyun içi metinler bitişik ("2oldun !") | Metinlerde boşluk eksik | `sv_plugin.lua`, `cl_panels.lua`, `sh_kitap.lua` içindeki ilgili metinlere boşluk ekle |

**Büyü verilmiyor ise:** `Config.GiveSpell` içindeki `HpwRewrite:LearnSpell(client, spell)` çağrısı, kullandığın HP Wand Rewrite sürümüne göre farklı olabilir. Sunucu konsolunda `lua_run PrintTable(HpwRewrite)` ile mevcut fonksiyonlara bakıp doğru çağrıyı `GiveSpell` içine yaz.

**Genel hata ayıklama:** Sunucu konsoluna (`lua_run`) ve istemci konsoluna (`lua_run_cl`) hata düşüp düşmediğine bak. Bir fonksiyonu elle denemek için:
```
lua_run ix.ven.kg.AddXP(player.GetByID(1), "botanik", 50)
```

---

## 14. Pluginde Bilinen Sınırlamalar

- **Görev sistemi WIP.** Altyapı var, tanımlı görev yok.
- **NPC modeli entity dosyasında sabit.** Config'deki `model` alanı kullanılmıyor.
- **Büyü entegrasyonu doğrulanmadı.** Varsayılan `HpwRewrite:LearnSpell` çağrısı farklı sürümlerde çalışmayabilir (config yorumunda da belirtilmiş).
- **Kitap tier'ları index ile saklanır.** Mevcut tier'ları silmek/sıralamayı değiştirmek var olan kitapları etkiler.
- **`/VenKGNpcEkle` hata mesajı sabit.** Yeni NPC eklenince metin elle güncellenmeli.
- **Item verme komutuyla** (`CharGiveItem`) tier seçilemez; hep Seviye 1 olur.
- **Karakter silinince** `ix_ven_kg_*` tablolarındaki o karaktere ait satırlar otomatik temizlenmez.
- **Para ödülü** (`reward.money`) için `char:GiveMoney` kullanılır; para sisteminin buna uyumlu olduğundan emin ol.
- **İkon yolları:** `sh_config.lua`'daki mevcut `icon` değerleri `materials/` önekiyle yazılı. İkonların görünmesi için yolun `materials/` klasörüne göre olması gerekir, bkz. [İkon yolları](#ikon-yolları).
- **Kozmetik:** Bazı oyun içi metinlerde boşluk eksik (ör. "seviye 2oldun !", "BakımıKitabı", "3rastgele kitap").

---

*Ven'in Karakter Gelişim Sistemi · v0.1*
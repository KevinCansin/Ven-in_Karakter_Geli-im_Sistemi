PLUGIN.name = "Ven'in Karakter Gelişim Sistemi"
PLUGIN.author = "Ven"
PLUGIN.description = "Ven'in basit karakter gelişim sistemi."
PLUGIN.version = "0.1"

ix.ven = ix.ven or {}
ix.ven.kg = ix.ven.kg or {}
ix.ven.gui = ix.ven.gui or {}

ix.lang.AddTable("english", {venkgTab = "Karakter Gelisimi"})
ix.lang.AddTable("turkish", {venkgTab = "Karakter Gelişimi"})

ix.util.Include("sh_config.lua")

ix.flag.Add(ix.ven.kg.Config.TeachFlag, "Ders verme yetkisi.")

ix.util.Include("sh_commands.lua")
ix.util.Include("sv_database.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("cl_panels.lua")
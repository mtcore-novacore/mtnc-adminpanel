# 🛡️ MTNC Admin Panel — Multi-Framework FiveM & Web Suite (v3.0 Enterprise)

[![FiveM](https://img.shields.io/badge/FiveM-Ready-38bdf8?style=flat-square&logo=fivem)](https://fivem.net)
[![Frameworks](https://img.shields.io/badge/Frameworks-QBCore%20|%20QBox%20|%20ESX%20|%20vRP%20|%20Standalone%20|%20Custom-10b981?style=flat-square)](https://novacore.dk)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-Edge%20WAF%20Protected-f59e0b?style=flat-square&logo=cloudflare)](https://cloudflare.com)
[![Discord](https://img.shields.io/badge/Discord.js-v14%20Slash%20Commands-5865F2?style=flat-square&logo=discord)](https://discord.com)

Et professionelt, sikkert og dedikeret administrationssystem til FiveM med **In-Game NUI Tablet**, **Centralt Hovedkontor (`mtcore.novacore.dk`)**, **Tenant Webpanel (`adminpanel.novacore.dk`)** samt **Cloudflare Edge DDoS Skjold**.

> 👨‍💻 **Udviklet af:** MrWolfDk &amp; MrGuld  
> 🏢 **Platform:** MTNC NovaCore Enterprise Infrastructure

---

## 🌟 Hovedfunktioner

### 🎮 1. In-Game Remote NUI Tablet (`/mtncadmin` / `NUMPAD 8` / `F10`)
* **📊 360° System Analyse:** Live diagnostik over licensstatus, DDoS-skjold, ping, oxmysql latenstid og server load.
* **👥 Spillere:** Realtids spilleroversigt med identifiers (Discord, Steam, License), ping og handlinger (*Kick, Ban, Heal, Revive, Teleport, Bring, Godmode, Usynlig*).
* **🚗 Køretøjer:** Custom vehicle spawner med søgning, reparation, tuning og 1-klik sletning af forladte biler.
* **💰 Økonomi:** Indsæt eller træk kontanter og bankpenge direkte på spillerens konto.
* **🌦️ Verden & Vejr:** Skift vejrtype (*Solskin, Regn, Torden, Tåge, Sne*) og server-tid med global synkronisering.
* **⚡ Noclip Engine:** Flyv frit med `W/A/S/D`, `Space` (Op), `Ctrl` (Ned) og `Shift` (Speed Boost).
* **📜 Revisionslogs & SOS:** Live handlingslog og direkte SOS-knap der sender en prioriteret alarm til Hovedkontoret.

### 🌐 2. Web Platforme & Multi-Node Arkitektur
* **🏢 Hovedkontor (`https://mtcore.novacore.dk`):**
  * Central licensoprettelse og styring (*Starter, Pro, Enterprise, Custom*).
  * Global overvågning af samtlige FiveM server noder og online spillertal.
  * 🛡️ **DDoS Skjold:** Cloudflare Edge WAF integration, 1-klik *Under Attack Mode* og live IP-sortliste.
  * 👥 **Staff Management:** Opret administratorer med granulære rettigheder og node-adgang.
  * 🔒 **Password Resets:** 1-klik godkendelse eller 2-minutters automatisk Discord DM flow.
* **🖥️ Tenant Adminpanel (`https://adminpanel.novacore.dk`):**
  * Dedikeret kontrolpanel for den enkelte serverejer og deres staff-team.
* **⚡ API Service (`https://api.novacore.dk`):**
  * Hurtig to-vejs WebSocket synkronisering mellem web og FiveM spilservere.

### 🔓 3. Åbne Framework-Adaptere & Tilpasning
For at give serverejere maksimal frihed er alle framework-filer **100% åbne og ukrypterede**:
* `qbcore` ➔ [`client/framework/qbcore.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/qbcore.lua) & [`server/framework/qbcore.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/qbcore.lua)
* `qbox` ➔ [`client/framework/qbox.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/qbox.lua) & [`server/framework/qbox.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/qbox.lua)
* `esx` ➔ [`client/framework/esx.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/esx.lua) & [`server/framework/esx.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/esx.lua)
* `vrp` ➔ [`client/framework/vrp.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/vrp.lua) & [`server/framework/vrp.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/vrp.lua)
* `standalone` ➔ [`client/framework/standalone.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/standalone.lua) & [`server/framework/standalone.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/standalone.lua)
* `custom` ➔ [`client/framework/custom.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/client/framework/custom.lua) & [`server/framework/custom.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/server/framework/custom.lua)

---

## 📡 `apiconnect.lua` Integration & Exports

Scriptet indeholder en åben [`apiconnect.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/apiconnect.lua) fil, så dine egne 3. parts FiveM scripts kan interagere direkte med MTNC:

### 1. Kør en System Analyse fra dit eget script:
```lua
local analysis = exports['mtnc-adminpanel']:Analyse()
print("Licens Status:", analysis.license.active)
print("DDoS Skjold:", analysis.ddos.shieldActive)
print("OxMySQL Status:", analysis.db.connected)
```

### 2. Tjek Spiller-Rettigheder:
```lua
-- Tjek om spilleren har tilladelse til en specifik handling
local hasPerm = exports['mtnc-adminpanel']:HasPermission(source, "player.ban")
if hasPerm then
    print("Spilleren må banne")
end
```

### 3. Send Revisionslog til Hovedkontor:
```lua
exports['mtnc-adminpanel']:SendAuditLog("CUSTOM_EVENT", "Spiller åbnede hemmelig boks")
```

---

## 📦 Installation & Opsætning

### 1. Placering af ressourcen
Kopier `mtnc-adminpanel` mappen ind i din FiveM servers `resources/` bibliotek.

### 2. Indsæt Licensnøgle
Åbn [`licensekey.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/licensekey.lua) og indsæt din licens:
```lua
-- licensekey.lua
return "MTNC-ENT-XXXX-XXXX"
```

### 3. Vælg Framework i `config.lua`
Åbn [`config.lua`](file:///C:/Users/thoma/Desktop/mtnc-adminpanel/config.lua):
```lua
Config = {}

-- Vælg dit framework: "qbcore", "qbox", "esx", "vrp", "standalone" eller "custom"
Config.framework = "qbcore"

Config.general = {
    openCommand   = "mtncadmin", -- Hovedkommando (/mtncadmin, /mtncmenu, /admin)
    defaultKey    = "NUMPAD8",   -- Tastatursnitflade
    secondaryKey  = "F10",       -- Alternativ tast
    closeKey      = 322,         -- ESC tast
}
```

### 4. Start i `server.cfg`
Tilføj følgende linje i din `server.cfg`:
```cfg
ensure mtnc-adminpanel
```

---

## 🤖 Discord Bot & Slash Commands

Platformens indbyggede Discord bot understøtter både Slash Commands (`/`) og klassiske prefix-kommandoer (`!`):

| Slash Command | Rettighed | Beskrivelse |
| :--- | :--- | :--- |
| `/help` | Alle | Viser komplet kommandoguide og platform links. |
| `/min-server` | Alle | Viser status, spillertal, IP og framework for dine noder. |
| `/min-license` | Alle | Sender dine aktive licenser og udløbsdatoer i en privat DM. |
| `/fivem-commands` | Alle | Viser in-game tablet genveje og noclip taster. |

---

## 🔒 Sikkerhed & Escrow Arkitektur

* **Kernebeskyttelse:** Alle 38 interne backend-filer er kompileret med polymorfisk Lua 5.4 VM og dynamisk bytecode obfuscation.
* **Escrow Ignore:** Følgende filer og mapper forbliver altid åbne og modificerbare for serverejere:
  * `config.lua`
  * `licensekey.lua`
  * `apiconnect.lua`
  * `client/framework/*`
  * `server/framework/*`
  * `html/*`

---

## 📞 Support & Hovedkontor
* **MTCore Hovedkontor:** [https://mtcore.novacore.dk](https://mtcore.novacore.dk)
* **Adminpanel:** [https://adminpanel.novacore.dk](https://adminpanel.novacore.dk)
* **API Service:** [https://api.novacore.dk](https://api.novacore.dk)

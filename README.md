# 🛡️ MTNC Admin Panel — FiveM & Web Platform (v2.5)

Et avanceret, sikkert og dedikeret administration- og styringspanel til FiveM med fuld **In-Game Remote NUI** samt et **Web Admin Panel** for multi-tenant administration.

---

## ✨ Funktioner

- **🔐 Dobbelt Autentificering & Sikkerhed:**
  - Login med **Brugernavn**, **Adgangskode** og **Sikkerhedskode (PIN)** for at forhindre uautoriseret adgang.
  - Role-Based Access Control (RBAC): `SUPERADMIN`, `ADMIN`, `MANAGER`, `VIEWER`.

- **🎮 Remote Hosted In-Game NUI (`/admin` / `NUMPAD8`):**
  - **👥 Spillere:** Realtids-liste over online spillere med ping, identifiers og direkte `Kick`, `Ban` og `TP` muligheder.
  - **⚡ Handlinger:** Broadcast globale beskeder, teleportation, Heal, GodMode, NoClip og Clear Wanted.
  - **🚗 Køretøjer:** Custom vehicle spawner samt quick-spawn knapper (Adder, Police, Ambulance, Buzzard, Sultan RS, Zentorno).
  - **🌤️ Vejr & Tid:** Skift vejrtype (Klart, Regn, Storm, Tåge, Sne, Solskin) og sæt server-tid.
  - **📊 Metrics:** Realtid CPU% og RAM telemetri fra host-maskinen.
  - **📜 Audit Logs:** Live event logs direkte fra backend serveren.
  - **⌨️ ESC-lukning:** Tryk `ESC` for øjeblikkeligt at lukke NUI-menuen og få musen tilbage.

- **🌐 Dedikeret Web Admin Panel:**
  - Hver FiveM server får sin egen dedikerede URL baseret på serverens IP og licens:
    `http://127.0.0.1:3009/admin/node_mtnc_ent_[sidste6cifreIP]`
  - Kan tilgås direkte fra din browser eller via reverse-proxy (`https://mtcore.novacore.dk/admin/...`).

- **💬 Discord Webhook Integration:**
  - Automatiske notifikationer ved bans, kicks og admin handlinger direkte til din Discord kanal.

---

## 🔑 Standard Logins

Ved første opstart er følgende SuperAdmin konto aktiv:

| Felt | Værdi |
|------|-------|
| **Brugernavn** | `superadmin` |
| **Adgangskode** | `admin123` |
| **Sikkerhedskode (PIN)** | `1234` |

> 💡 **Tip:** Du kan ændre din adgangskode og PIN-kode i **Indstillinger** fanen i admin panelet.

---

## 📦 Installation & Opsætning

### 1. Placering af resource
Kopier `mtnc-adminpanel` mappen til din FiveM servers `resources/` directory.

### 2. Opsætning af Licensnøgle
Åbn `licensekey.lua` i ressourcens rodmappe og indsæt din licensnøgle:

```lua
-- licensekey.lua
return "MTNC-ENT-2026-9988-X7"
```

### 3. Tilføj til `server.cfg`
Åbn din `server.cfg` og tilføj følgende linje:

```cfg
ensure mtnc-adminpanel
```

---

## ⚙️ Konfiguration (`config.lua`)

Du kan tilpasse genvejstaster og kommandoer i `config.lua`:

```lua
Config = {}

Config.general = {
    openCommand = "admin",  -- Kommando til at åbne menuen (/admin)
    defaultKey  = "NUMPAD8",-- Tastatur genvej
    closeKey    = 322,      -- ESC tast ID til at lukke menuen
}
```

---

## 🚀 Automatisk Node Registrering & URLs

Når din FiveM server starter op med en gyldig `licensekey.lua`, registrerer den sig automatisk hos API serveren (`api.novacore.dk`) og udskriver din dedikerede Admin Panel URL i server konsollen:

```
[MTNC] 🟢 Server registreret succesfuldt hos MTNC API!
[MTNC] 🌐 DEDIKERET ADMIN PANEL URL: http://127.0.0.1:3009/admin/node_mtnc_ent_884120
```

---

## ⚠️ Vigtigt

- Uden en gyldig licensnøgle i `licensekey.lua` vil serveren ikke kunne registrere sin node eller åbne admin panelet.
- API'et køres internt og skal køre på den valgte backend port (`3009`).

God fornøjelse med **MTNC Admin Panel**! 🚀
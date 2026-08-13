# 📱 MTNC ADMIN TABLET v3.0.2 — CHANGELOG
**NovaCore × MTCore © 2026**
*Udviklere: MrWolfDk & MrGuld*

---

### 🚀 NYHEDER (v3.0.2)
- **Live Database Køretøjsopslag**: *Køretøjer* appen henter nu data i realtid direkte fra MySQL databasen via `oxmysql` (`player_vehicles` / `owned_vehicles`). Viser nummerplade, model, garage, benzinniveau (%), motorstand (%) og karosseristand (%).
- **📍 GPS Rutevejledning**: Direkte waypoint-knap til alle dine parkerede biler.
- **🌍 Fuld Multi-Language (i18n)**: Vælg direkte mellem 🇩🇰 Dansk, 🇬🇧 English, 🇩🇪 Deutsch, 🇸🇪 Svenska og 🇳🇴 Norsk i Indstillinger-appen.
- **Lasergraveret MTNC Hardware Branding**: Fysisk MTNC emblem på rammen og MTNC 5G indikator.

---

### 🔒 SIKKERHED & CLOUD
- **Krypteret In-Memory API Resolver**: Backend URL'er er 100% krypteret med XOR byte-arrays og dekrypteres udelukkende i serverens RAM.
- **Standard Cloud HTTPS**: Kommunikerer direkte mod `https://api.novacore.dk` uden custom porte.
- **Fuldstændig Ren `licensekey.lua`**: Kun kundenøglen er synlig for kunder.
- **LB Phone PIN-Nulstilling**: 30 minutters cooldown og staff-godkendelseskø.

---

### ⚡ FORBEDRINGER & ARKITEKTUR
- **🚫 INGEN INVENTAR**: Al inventar-kode er 100% fjernet for maksimal kompatibilitet.
- **🚫 INGEN WEB ADMINPANEL**: Alt administration foregår 100% in-game i tabletten.
- **Framework Bridges**: Autodetektion for QBCore, Qbox, ESX og vRP.
- **Multijob System**: Autoritativ håndtering af primære og sekundære jobs samt vagtstatus.

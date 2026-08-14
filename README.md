# ⚡ MTNC Admin Tablet & Platform v3.0.2
**Officielt leveret af NovaCore & MTCore**

---

### 📦 INSTALLATIONSVEJLEDNING (Kunde)

1. **Flyt Mappen**:
   - Træk mappen `mtnc-adminpanel` ind i din FiveM server mappe under `resources/` (f.eks. `resources/[mtnc]/mtnc-adminpanel`).

2. **Importer Database**:
   - Åbn din FiveM database (HeidiSQL eller phpMyAdmin) og kør SQL-filen:
     `install.sql`

3. **Indsæt Licensnøgle**:
   - Åbn filen `licensekey.lua` med Notepad eller VS Code.
   - Indsæt din licensnøgle som du har modtaget via Discord (`/license`) eller MTCore portalen:
     ```lua
     Config = Config or {}
     Config.LicenseKey = "INDSAET_DIN_LICENS_HER"
     ```

4. **Konfiguration**:
   - Åbn `config/config.lua` for at tilpasse servernavn, åbne-tast (standard F10 / /admin), tilladelser, webhooks og sprog.

5. **Start i server.cfg**:
   - Tilføj følgende linje i din `server.cfg`:
     ```cfg
     ensure mtnc-adminpanel
     ```

6. **Genstart din FiveM Server**:
   - Genstart serveren, og adminpanelet er klar til brug!

---
© 2026 NovaCore & MTCore · Udviklet af MrWolfDk & MrGuld

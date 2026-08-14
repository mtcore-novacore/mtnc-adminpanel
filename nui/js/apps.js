// ============================================================
// MTNC TABLET OS v3.0.2 — CURATED APPLICATION SUITE
// ============================================================

function getAppsList() {
  return [
    { id: 'profile', name: t('app_profile') || 'Profil', icon: '👤', bg: 'linear-gradient(135deg, #2563eb, #1d4ed8)', isStaffOnly: false, isBossOnly: false },
    { id: 'jobs', name: t('app_jobs') || 'Jobs', icon: '💼', bg: 'linear-gradient(135deg, #d97706, #b45309)', isStaffOnly: false, isBossOnly: false },
    { id: 'boss', name: 'Firma / Boss', icon: '🏢', bg: 'linear-gradient(135deg, #059669, #047857)', isStaffOnly: false, isBossOnly: true },
    { id: 'vehicles', name: t('app_vehicles') || 'Køretøjer', icon: '🚗', bg: 'linear-gradient(135deg, #dc2626, #b91c1c)', isStaffOnly: false, isBossOnly: false },
    { id: 'housing', name: t('app_housing') || 'Bolig', icon: '🏠', bg: 'linear-gradient(135deg, #0891b2, #0e7490)', isStaffOnly: false, isBossOnly: false },
    { id: 'reports', name: t('app_reports') || 'Rapporter', icon: '📋', bg: 'linear-gradient(135deg, #7c3aed, #6d28d9)', isStaffOnly: false, isBossOnly: false },
    { id: 'settings', name: t('app_settings') || 'Indstillinger', icon: '⚙️', bg: 'linear-gradient(135deg, #475569, #334155)', isStaffOnly: false, isBossOnly: false },
    { id: 'admin', name: t('app_admin') || 'Admin', icon: '🛡️', bg: 'linear-gradient(135deg, #ca8a04, #a16207)', isStaffOnly: true, isBossOnly: false }
  ];
}

const Renderers = {
  // 👤 1. Profil
  profile(state) {
    const s = state.session || {};
    const p = state.profile || {};
    const job = p.primaryJob || { label: 'Arbejdsløs', gradeLabel: 'Borger', duty: false, salary: 0 };

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('profile_title') || '👤 Min Profil'}</h2>
            <p class="app-heading-sub">Officielle identitets- og borgerdata</p>
          </div>
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">🪪 Karakter Identifikation</div>
          <div class="os-card-row"><span class="row-label">Navn</span><span class="row-value">${p.name || 'Thomas'}</span></div>
          <div class="os-card-row"><span class="row-label">Server ID</span><span class="row-value">#${p.serverId || 1}</span></div>
          <div class="os-card-row"><span class="row-label">Primært Erhverv</span><span class="row-value">${job.label}</span></div>
          <div class="os-card-row"><span class="row-label">Stilling / Grad</span><span class="row-value">${job.gradeLabel}</span></div>
          <div class="os-card-row"><span class="row-label">Vagtstatus</span><span class="row-value" style="color:${job.duty ? 'var(--sys-green)' : 'var(--text-muted)'};">${job.duty ? '🟢 På vagt' : '⚪ Fri'}</span></div>
        </div>

        <div class="os-card">
          <div class="os-card-title">💼 Arbejdskontrakt &amp; Løn</div>
          <div class="os-card-row"><span class="row-label">Timeløn</span><span class="row-value">${job.salary || 0} DKK</span></div>
          <div class="os-card-row"><span class="row-label">Ledelsesstatus</span><span class="row-value">${job.isBoss ? '👑 Chef / Ledelse' : '👤 Medarbejder'}</span></div>
          <div style="margin-top: 18px;">
            <button class="sys-btn sys-btn-primary" style="width: 100%;" onclick="API.post('toggleDuty'); App.showToast('Skiftede vagtstatus', 'info')">
              ${job.duty ? '⚪ Gå af vagt' : '🟢 Gå på vagt'}
            </button>
          </div>
        </div>
      </div>
    `;
  },

  // 💼 2. Multijob & Jobs
  jobs(state) {
    const data = state.jobsData || { primary: state.profile?.primaryJob, list: [state.profile?.primaryJob || { name:'unemployed', label:'Arbejdsloes', gradeLabel:'Borger', duty:false, salary:0 }] };
    const list = data.list || [];
    const primary = data.primary || list[0] || {};

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('multijob_title') || '💼 Jobs & Erhverv'}</h2>
            <p class="app-heading-sub">Administrer dine aktive ansættelser og vagtstatus</p>
          </div>
        </div>
      </div>

      <div class="os-card" style="margin-bottom: 16px;">
        <div class="os-card-title">🟢 Aktivt Primært Erhverv</div>
        <div class="job-item-card is-primary">
          <div>
            <div style="font-size: 1.1rem; font-weight: 800; color: #fff;">${primary.label || 'Arbejdsløs'}</div>
            <div style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 3px;">
              Grad: <strong>${primary.gradeLabel || 'Borger'}</strong> · Løn: <strong>${primary.salary || 0} DKK</strong>
            </div>
          </div>
          <button class="sys-btn ${primary.duty ? 'sys-btn-secondary' : 'sys-btn-primary'}" onclick="API.post('toggleDuty')">
            ${primary.duty ? '⚪ Gå af vagt' : '🟢 Gå på vagt'}
          </button>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">📋 Alle Dine Ansættelser (${list.length})</div>
        ${list.map(j => `
          <div class="job-item-card" style="margin-bottom: 10px;">
            <div>
              <div style="font-weight: 700; color: #fff;">${j.label} (${j.gradeLabel})</div>
              <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 2px;">Løn: ${j.salary} DKK / time</div>
            </div>
            ${j.name !== primary.name ? `
              <button class="sys-btn sys-btn-secondary" onclick="API.post('switchJob', { job: '${j.name}', grade: ${j.grade || 0} })">
                🔄 Skift til dette job
              </button>
            ` : '<span class="badge" style="background: rgba(16,185,129,0.15); color: var(--sys-green);">Aktiv</span>'}
          </div>
        `).join('')}
      </div>
    `;
  },

  // 🏢 3. Firma / Boss Ledelse
  boss(state) {
    const b = state.bossData || { isBoss: false, job: { label: 'Dit Firma', grade: 'Chef' }, balance: 0, employees: [] };
    const employees = b.employees || [];
    const isBoss = b.isBoss;

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">🏢 ${b.job.label || 'Firma & Ledelse'}</h2>
            <p class="app-heading-sub">${isBoss ? '👑 Ledelsespanel & Firmastyring' : '👤 Medarbejderoversigt'}</p>
          </div>
        </div>
        <button class="sys-btn sys-btn-secondary" onclick="API.post('getBossData'); App.showToast('Opdaterer firma data...', 'info')">🔄 Opdater</button>
      </div>

      <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 14px; margin-bottom: 18px;">
        <div class="os-card" style="border-left: 3px solid var(--sys-green);">
          <div class="os-card-title">🏦 Firma-Konto Saldo</div>
          <div style="font-size: 1.6rem; font-weight: 800; color: #fff; margin-top: 6px;">${(b.balance || 0).toLocaleString()} <span style="font-size: 0.9rem; color: var(--sys-green);">DKK</span></div>
          <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 4px;">${b.job.label} Society Fund</div>
        </div>
        <div class="os-card" style="border-left: 3px solid #60a5fa;">
          <div class="os-card-title">👥 Ansatte Medarbejdere</div>
          <div style="font-size: 1.6rem; font-weight: 800; color: #fff; margin-top: 6px;">${employees.length}</div>
          <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 4px;">Aktive kontrakter</div>
        </div>
      </div>

      ${isBoss ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">⚡ Ledelses Handlinger</div>
          <div style="display: flex; gap: 10px; flex-wrap: wrap; margin-top: 10px;">
            <button class="sys-btn sys-btn-primary" onclick="App.promptBossDeposit()">💵 Indsæt Penge på Konto</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptBossWithdraw()">💳 Hæv Penge fra Konto</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptBossHire()">➕ Ansæt Ny Medarbejder</button>
          </div>
        </div>
      ` : ''}

      <div class="os-card">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
          <div class="os-card-title">👥 Medarbejder Roster (${employees.length})</div>
          ${isBoss ? '<button class="sys-btn sys-btn-primary" style="font-size:0.78rem;" onclick="App.promptBossHire()">+ Ansæt Spiller</button>' : ''}
        </div>

        ${employees.length === 0 ? `
          <div style="padding: 32px; text-align: center; color: var(--text-muted); font-size: 0.85rem;">
            Ingen registrerede medarbejdere fundet i dette firma.
          </div>
        ` : ''}

        ${employees.map(e => `
          <div class="job-item-card" style="margin-bottom: 10px;">
            <div style="flex: 1;">
              <div style="display: flex; align-items: center; gap: 8px;">
                <span style="font-weight: 800; color: #fff; font-size: 1.02rem;">${e.name}</span>
                <span class="badge" style="background: ${e.isBoss ? 'rgba(245,158,11,0.2)' : 'rgba(59,130,246,0.15)'}; color: ${e.isBoss ? 'var(--sys-orange)' : '#60a5fa'}; font-weight: 700;">
                  ${e.gradeName} (${e.grade})
                </span>
                ${e.isBoss ? '<span style="font-size:0.75rem; color:var(--sys-orange); font-weight:700;">👑 Ledelse</span>' : ''}
              </div>
              <div style="font-size: 0.76rem; color: var(--text-secondary); margin-top: 4px; display: flex; gap: 12px; flex-wrap: wrap;">
                <span>Citizen ID: <strong>${e.citizenid}</strong></span>
                <span>Løn: <strong>${e.salary} DKK / time</strong></span>
              </div>
            </div>
            ${isBoss && !e.isBoss ? `
              <div style="display: flex; gap: 6px;">
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem;" onclick="App.promptBossSetGrade('${e.citizenid}', '${e.name}')">👔 Skift Rang</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; color: var(--sys-red);" onclick="App.confirmBossFire('${e.citizenid}', '${e.name}')">🚪 Fyr</button>
              </div>
            ` : ''}
          </div>
        `).join('')}
      </div>
    `;
  },

  // 🚗 4. Køretøjer
  vehicles(state) {
    const list = state.vehicles || [];
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('vehicles_title') || '🚗 Mine Køretøjer'}</h2>
            <p class="app-heading-sub">Registrerede biler og teknisk tilstand</p>
          </div>
        </div>
        <button class="sys-btn sys-btn-secondary" onclick="API.post('getVehicles'); App.showToast('Opdaterer biler...', 'info')">🔄 Opdater</button>
      </div>

      <div class="os-card">
        <div class="os-card-title">🚗 Registrerede Biler (${list.length})</div>
        ${list.length === 0 ? `
          <div style="padding: 40px 16px; text-align: center; color: var(--text-muted);">
            <div style="font-size: 2.4rem; margin-bottom: 10px;">🚗</div>
            <div style="font-size: 1.1rem; font-weight: 700; color: #fff; margin-bottom: 6px;">Ingen registrerede køretøjer</div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); max-width: 340px; margin: 0 auto; line-height: 1.5;">
              Du ejer i øjeblikket ingen køretøjer i DMV-databasen for denne karakter.
            </div>
          </div>
        ` : ''}
        ${list.map(v => `
          <div class="job-item-card" style="margin-bottom: 12px;">
            <div style="flex: 1;">
              <div style="display: flex; align-items: center; gap: 10px;">
                <span style="font-size: 1.05rem; font-weight: 800; color: #fff;">${v.model}</span>
                <span style="background: rgba(255,255,255,0.08); border: 1px solid var(--border-subtle); padding: 2px 8px; border-radius: 6px; font-family: var(--font-mono); font-size: 0.78rem; font-weight: 700; color: #60a5fa;">${v.plate}</span>
              </div>
              <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 6px; display: flex; gap: 14px; flex-wrap: wrap;">
                <span>📍 Garage: <strong>${v.garage}</strong></span>
                <span>⛽ Benzin: <strong>${v.fuel}%</strong></span>
                <span>🔧 Motor: <strong>${v.engine}%</strong></span>
                <span>🛡️ Karosseri: <strong>${v.body}%</strong></span>
                <span style="color: ${v.state === 'I Garage' ? 'var(--sys-green)' : 'var(--sys-orange)'};">● ${v.state}</span>
              </div>
            </div>
            <button class="sys-btn sys-btn-secondary" onclick="App.showToast('📍 GPS waypoint sat til ' + '${v.garage}', 'success')">
              📍 Sæt GPS
            </button>
          </div>
        `).join('')}
      </div>
    `;
  },

  // 🏠 5. Bolig
  housing(state) {
    const list = state.houses || [];
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('housing_title') || '🏠 Bolig & Ejendomme'}</h2>
            <p class="app-heading-sub">Registrerede adresser og nøglehavere</p>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">🏠 Registrerede Boliger (${list.length})</div>
        ${list.length === 0 ? `
          <div style="padding: 40px 16px; text-align: center; color: var(--text-muted);">
            <div style="font-size: 2.4rem; margin-bottom: 10px;">🏠</div>
            <div style="font-size: 1.1rem; font-weight: 700; color: #fff; margin-bottom: 6px;">Ingen registrerede boliger</div>
            <div style="font-size: 0.85rem; color: var(--text-secondary); max-width: 340px; margin: 0 auto; line-height: 1.5;">
              Du ejer i øjeblikket ingen boliger eller ejendomme for denne karakter.
            </div>
          </div>
        ` : ''}
        ${list.map(h => `
          <div class="job-item-card" style="margin-bottom: 12px;">
            <div>
              <div style="font-size: 1rem; font-weight: 700; color: #fff;">${h.label || h.name}</div>
              <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 2px;">
                Garagepladser: ${h.garage || 1} biler · Nøgler: ${h.keyholders ? h.keyholders.length : 1}
              </div>
            </div>
            <button class="sys-btn sys-btn-secondary" onclick="App.showToast('📍 GPS waypoint sat til ' + '${h.label || h.name}', 'success')">
              📍 Sæt GPS
            </button>
          </div>
        `).join('')}
      </div>
    `;
  },

  // 📋 6. Rapporter & Sager
  reports(state) {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('reports_title') || '📋 Opret Rapport'}</h2>
            <p class="app-heading-sub">Kontakt serverens staff-team direkte</p>
          </div>
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">📝 Ny Henvendelse / Sag</div>
          <form onsubmit="App.submitReport(event)">
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">Kategori</label>
            <select id="rep-category" class="sys-select" style="margin-bottom:10px;">
              <option>Spiller Report</option>
              <option>Bug / Teknisk Fejl</option>
              <option>Spørgsmål til Staff</option>
            </select>
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">Involveret Spiller ID (Valgfrit)</label>
            <input type="number" id="rep-target" class="sys-input" placeholder="F.eks. 42" style="margin-bottom:10px;">
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">Beskrivelse</label>
            <textarea id="rep-reason" required class="sys-textarea" rows="3" placeholder="Beskriv hændelsen så præcist som muligt..." style="margin-bottom:14px;"></textarea>
            <button type="submit" class="sys-btn sys-btn-primary" style="width:100%;">🚀 Send Rapport til Staff</button>
          </form>
        </div>

        <div class="os-card">
          <div class="os-card-title">ℹ️ Information &amp; Retningslinjer</div>
          <p style="font-size:0.82rem; color:var(--text-secondary); line-height:1.5;">
            Brug denne funktion med omtanke. Falske anmeldelser eller spam kan medføre advarsler eller udelukkelse fra serveren.<br><br>
            Staff-teamet modtager din henvendelse direkte i deres kontrolpanel og behandler den hurtigst muligt.
          </p>
        </div>
      </div>
    `;
  },

      // ⚙️ 7. Indstillinger & Tema Vælger (Inkl. Politi & Læge Special-Temaer)
  settings(state) {
    let curLang = 'da';
    let curTheme = state.theme || 'modern';
    try {
      if (typeof window !== 'undefined' && window.localStorage) {
        curLang = window.localStorage.getItem('mtnc_tablet_lang') || 'da';
        curTheme = window.localStorage.getItem('mtnc_tablet_theme') || curTheme;
      }
    } catch(e) {}

    const jobName = (state.profile?.primaryJob?.name || '').toLowerCase();
    const isPolice = jobName.includes('police') || jobName.includes('politi') || jobName.includes('sheriff');
    const isEMS = jobName.includes('ambulance') || jobName.includes('ems') || jobName.includes('doctor') || jobName.includes('laege') || jobName.includes('hospital');

    const themesList = [
      { id: 'modern', name: '🌌 Obsidian Titanium', desc: 'Standard mørk luksus pro' },
      { id: 'retro95', name: '💾 Retro 90s Windows', desc: 'Klassisk Win95 nostalgi & teal' },
      { id: 'cyberpunk', name: '📟 Cyberpunk 80s Neon', desc: 'Synthwave, pink & cyan neon' },
      { id: 'gameboy', name: '👾 GameBoy Classic 1989', desc: 'Retro 4-tonet oliven LCD' },
      { id: 'matrix', name: '🟢 Matrix CRT Terminal', desc: 'Hacker grøn fosfor' },
      { id: 'mac84', name: '🍏 Retro Macintosh 1984', desc: 'Vintage monokrom klassiker' },
      { id: 'vice', name: '🌇 Vice City 80s Sunset', desc: 'Miami solnedgang & fersken' },
      { id: 'crimson', name: '🩸 Crimson Blood Red', desc: 'Dyb vampyr rød & rubin' },
      { id: 'nordic', name: '💎 Nordic Arctic Ice', desc: 'Frostblå gletsjer atmosfære' },
      { id: 'gold', name: '👑 Royal Gold & Onyx', desc: 'Guld luksus & champagnestil' },
      { id: 'sakura', name: '🌸 Tokyo Sakura Pastel', desc: 'Vaporwave, pink & lavendel' },
      { id: 'mocha', name: '☕ Café Mocha Retro', desc: 'Varm ristet kaffe & karamel' }
    ];

    // Exclusive Job-Specific Themes
    if (isPolice) {
      themesList.unshift({
        id: 'police',
        name: t('theme_police_name') || '👮 Rigspoliti Taktisk',
        desc: t('theme_police_desc') || 'Eksklusivt operativt politi & MDT tema',
        badge: t('theme_badge_service') || 'Tjenestetema'
      });
    }

    if (isEMS) {
      themesList.unshift({
        id: 'ambulance',
        name: t('theme_ems_name') || '🚑 Akutlæge & EMS Hospital',
        desc: t('theme_ems_desc') || 'Eksklusivt medicinsk ambulance tema',
        badge: t('theme_badge_service') || 'Tjenestetema'
      });
    }

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('settings_title') || '⚙️ Indstillinger'}</h2>
            <p class="app-heading-sub">Systemsprog, retro temaer og præferencer</p>
          </div>
        </div>
      </div>

      <!-- 🎨 Theme Selection Card -->
      <div class="os-card" style="margin-bottom: 20px;">
        <div class="os-card-title">🎨 Vælg Tablet Tema (Retro, Moderne &amp; Tjeneste)</div>
        <p style="font-size:0.82rem; color:var(--text-secondary); margin-bottom:14px;">Vælg dit personlige tablet-udseende:</p>
        <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap:12px;">
          ${themesList.map(th => `
            <div class="job-item-card ${curTheme === th.id ? 'is-primary' : ''}" style="cursor:pointer; margin-bottom:0;" onclick="App.setTheme('${th.id}')">
              <div>
                <div style="display:flex; align-items:center; gap:6px;">
                  <span style="font-weight:800; font-size:0.95rem; color:#fff;">${th.name}</span>
                  ${th.badge ? `<span class="badge" style="background:rgba(37,99,235,0.25); color:#60a5fa; font-size:0.68rem;">${th.badge}</span>` : ''}
                </div>
                <div style="font-size:0.75rem; color:var(--text-secondary); margin-top:2px;">${th.desc}</div>
              </div>
              ${curTheme === th.id ? '<span class="badge" style="background:rgba(16,185,129,0.25); color:var(--sys-green);">Aktiv</span>' : ''}
            </div>
          `).join('')}
        </div>
      </div>

      <!-- 🌐 Language Selection Card -->
      <div class="os-card" style="margin-bottom: 20px;">
        <div class="os-card-title">🌐 Vælg Sprog (Language)</div>
        <p style="font-size:0.82rem; color:var(--text-secondary); margin-bottom:14px;">Vælg dit foretrukne sprog til tabletten:</p>
        <div style="display:flex; gap:10px; flex-wrap:wrap;">
          ${Object.entries(Locales).map(([code, data]) => `
            <button class="sys-btn ${curLang === code ? 'sys-btn-primary' : 'sys-btn-secondary'}" onclick="App.setLanguage('${code}')" style="padding:10px 20px;">
              ${data.flag} ${data.name}
            </button>
          `).join('')}
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">📱 Enhed &amp; System Information</div>
        <div class="os-card-row"><span class="row-label">Operativsystem</span><span class="row-value">MTNC Tablet OS v3.0.2</span></div>
        <div class="os-card-row"><span class="row-label">Aktivt Tema</span><span class="row-value">${curTheme.toUpperCase()}</span></div>
        <div class="os-card-row"><span class="row-label">Cloud Gateway</span><span class="row-value">api.novacore.dk (Aktiv)</span></div>
      </div>
    `;
  },

  // 🛡️ 8. Master Admin & Staff Suite
  admin(state) {
    const s = state.session || {};
    const reports = state.reports || [];
    const tab = state.adminTab || 'overview';
    const players = state.adminPlayers || [];
    const searchMatches = state.adminVehMatches || [];
    const staffList = state.adminStaff || [];
    const auditLogs = state.adminAuditLogs || [];
    const bansList = state.adminBans || [];

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('admin_title') || '🛡️ Staff Kontrolpanel'}</h2>
            <p class="app-heading-sub">Logget ind som <strong>${s.name || 'Staff'}</strong> (${s.role || 'admin'})</p>
          </div>
        </div>
        <button class="sys-btn sys-btn-secondary" onclick="App.refreshAdminData()">🔄 Opdater Alt</button>
      </div>

      <!-- 10 Admin Tabs Navigation Bar -->
      <div class="admin-tab-nav" style="display: flex; gap: 6px; margin-bottom: 16px; flex-wrap: wrap;">
        <button class="sys-btn ${tab === 'overview' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('overview')">📊 Oversigt</button>
        <button class="sys-btn ${tab === 'players' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('players')">👥 Spillere (${players.length})</button>
        <button class="sys-btn ${tab === 'self' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('self')">⚡ Egen Karakter</button>
        <button class="sys-btn ${tab === 'weapons' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('weapons')">🔫 Våben</button>
        <button class="sys-btn ${tab === 'teleport' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('teleport')">📍 Teleport Hubs</button>
        <button class="sys-btn ${tab === 'vehicles' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('vehicles')">🚗 Køretøjer</button>
        <button class="sys-btn ${tab === 'world' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('world')">🌍 Verden &amp; Vejr</button>
        <button class="sys-btn ${tab === 'reports' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('reports')">📋 Rapporter (${reports.length})</button>
        <button class="sys-btn ${tab === 'staff' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('staff')">🛡️ Staff Medlemmer (${staffList.length})</button>
        <button class="sys-btn ${tab === 'bans' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('bans')">🔨 Bans (${bansList.length})</button>
        <button class="sys-btn ${tab === 'audit' ? 'sys-btn-primary' : 'sys-btn-secondary'}" style="font-size:0.8rem; padding:6px 12px;" onclick="App.setAdminTab('audit')">📜 Revisionslog (${auditLogs.length})</button>
      </div>

      <!-- TAB 1: 📊 OVERSIGT -->
      ${tab === 'overview' ? `
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 14px; margin-bottom: 18px;">
          <div class="os-card" style="padding: 16px; background: rgba(37, 99, 235, 0.15); border-color: rgba(59, 130, 246, 0.4);">
            <div style="font-size: 0.76rem; font-weight: 700; color: #93c5fd; text-transform: uppercase;">👥 Online Spillere</div>
            <div style="font-size: 1.8rem; font-weight: 900; color: #fff; margin-top: 4px;">${players.length}</div>
            <div style="font-size: 0.72rem; color: #cbd5e1; margin-top: 2px;">Aktive på FiveM serveren</div>
          </div>

          <div class="os-card" style="padding: 16px; background: rgba(16, 185, 129, 0.15); border-color: rgba(16, 185, 129, 0.4);">
            <div style="font-size: 0.76rem; font-weight: 700; color: #6ee7b7; text-transform: uppercase;">🛡️ Staff Medlemmer</div>
            <div style="font-size: 1.8rem; font-weight: 900; color: #fff; margin-top: 4px;">${staffList.length}</div>
            <div style="font-size: 0.72rem; color: #cbd5e1; margin-top: 2px;">Registrerede administratorer</div>
          </div>

          <div class="os-card" style="padding: 16px; background: rgba(245, 158, 11, 0.15); border-color: rgba(245, 158, 11, 0.4);">
            <div style="font-size: 0.76rem; font-weight: 700; color: #fcd34d; text-transform: uppercase;">📋 Åbne Rapporter</div>
            <div style="font-size: 1.8rem; font-weight: 900; color: #fff; margin-top: 4px;">${reports.length}</div>
            <div style="font-size: 0.72rem; color: #cbd5e1; margin-top: 2px;">Spillersager i kø</div>
          </div>
        </div>

        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">⚡ Hurtige Server Handlinger</div>
          <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 14px;">Udfør administrative handlinger over hele serveren med et enkelt klik.</p>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 10px;">
            <button class="sys-btn sys-btn-primary" style="padding: 12px; font-size: 0.88rem;" onclick="App.promptAnnounce()">📢 Udsend Server Announcement</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminServerAction', { action: 'reviveAll' })">⚡ Genopliv Alle Online</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminServerAction', { action: 'clearAreaVehicles' })">🧹 Ryd Forladte Biler</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'EXTRASUNNY' }); App.showToast('☀️ Sat vejr til Solrigt', 'success')">☀️ Sæt Vejr til Solrigt</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminServerAction', { action: 'setTime', val1: 12, val2: 0 }); App.showToast('🕒 Sat tid til 12:00', 'success')">🕒 Sæt Tid til Middag (12:00)</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminServerAction', { action: 'toggleBlackout' })">💥 Toggle By-Blackout</button>
          </div>
        </div>

        <div class="os-card">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div class="os-card-title">👥 Seneste Spillere &amp; Hurtig-Adgang</div>
            <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.setAdminTab('players')">Se Alle Spillere →</button>
          </div>
          ${players.length === 0 ? '<div style="padding: 16px; color: var(--text-muted); text-align: center; font-size: 0.85rem;">Henter spillere...</div>' : ''}
          <div style="display: flex; flex-direction: column; gap: 8px;">
            ${players.slice(0, 4).map(p => `
              <div class="job-item-card" style="margin-bottom: 0; padding: 10px 14px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                  <span style="background: rgba(59,130,246,0.15); border: 1px solid rgba(59,130,246,0.3); color: #60a5fa; padding: 2px 8px; border-radius: 6px; font-weight: 800; font-family: var(--font-mono); font-size: 0.78rem;">ID: ${p.id}</span>
                  <strong style="color: #fff;">${p.charName}</strong>
                  <span style="font-size: 0.78rem; color: var(--text-muted);">(@${p.name})</span>
                  <span style="font-size: 0.78rem; color: var(--text-secondary);">· ${p.job}</span>
                </div>
                <div style="display: flex; gap: 6px;">
                  <button class="sys-btn sys-btn-secondary" style="font-size: 0.72rem; padding: 3px 8px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'teleport' }); App.showToast('🚀 Teleporteret', 'success')">🚀 TP</button>
                  <button class="sys-btn sys-btn-secondary" style="font-size: 0.72rem; padding: 3px 8px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'bring' }); App.showToast('🧲 Bragte spiller', 'success')">🧲 Bring</button>
                  <button class="sys-btn sys-btn-secondary" style="font-size: 0.72rem; padding: 3px 8px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'revive' }); App.showToast('💉 Genoplivet', 'success')">💉 Revive</button>
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      ` : ''}

            <!-- TAB 2: 👥 SPILLERE -->
      ${tab === 'players' ? `
        <div class="os-card">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
            <div class="os-card-title">👥 Spillere på Serveren (${players.length})</div>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminGetPlayers')">🔄 Opdater Liste</button>
          </div>
          ${players.length === 0 ? '<div style="padding:20px; text-align:center; color:var(--text-muted);">Henter spillerliste fra serveren...</div>' : ''}
          ${players.map(p => `
            <div class="job-item-card" style="margin-bottom: 12px; flex-direction: column; align-items: flex-start; gap: 10px;">
              <div style="display: flex; justify-content: space-between; width: 100%; align-items: center; flex-wrap: wrap; gap: 8px;">
                <div style="display: flex; align-items: center; gap: 10px;">
                  <span style="background: rgba(59,130,246,0.15); border: 1px solid rgba(59,130,246,0.3); color: #60a5fa; padding: 2px 8px; border-radius: 6px; font-weight: 800; font-family: var(--font-mono);">ID: ${p.id}</span>
                  <span style="font-weight: 800; color: #fff; font-size: 1.05rem;">${p.charName}</span>
                  <span style="font-size: 0.8rem; color: var(--text-muted);">(@${p.name})</span>
                </div>
                <div style="display: flex; gap: 12px; font-size: 0.78rem; color: var(--text-secondary); flex-wrap: wrap;">
                  <span>👔 ${p.job} (${p.grade})</span>
                  ${p.gang && p.gang !== 'Ingen' ? `<span>🔫 ${p.gang} (${p.gangGrade})</span>` : ''}
                  <span>💵 ${p.cash.toLocaleString()} DKK</span>
                  <span>💳 ${p.bank.toLocaleString()} DKK</span>
                  <span style="color: ${p.ping < 50 ? 'var(--sys-green)' : 'var(--sys-orange)'};">📶 ${p.ping}ms</span>
                </div>
              </div>
              <div style="display: flex; gap: 6px; flex-wrap: wrap; width: 100%; padding-top: 6px; border-top: 1px solid rgba(255,255,255,0.06);">
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'teleport' }); App.showToast('🚀 Teleporteret til ' + '${p.charName}', 'success')">🚀 TP Til</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'bring' }); App.showToast('🧲 Bragte ' + '${p.charName}', 'success')">🧲 Bring</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'intovehicle' })">🚗 Hop Ind</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'openInventory' })">🎒 Åbn Inv</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'clearInventory' })">🧹 Tøm Inv</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'openClothing' })">👕 Tøjmenu</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'revive' }); App.showToast('💉 Genoplivede ' + '${p.charName}', 'success')">💉 Revive</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'heal' }); App.showToast('🩹 Healede ' + '${p.charName}', 'success')">🩹 Heal</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'giveArmor' }); App.showToast('🛡️ Gav 100% Panser', 'success')">🛡️ Panser</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'freeze' }); App.showToast('❄️ Frys status ændret', 'info')">❄️ Frys</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'spectate' })">👁️ Spectate</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptGiveMoney(${p.id}, '${p.charName}')">💰 Giv Penge</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptGiveItem(${p.id}, '${p.charName}')">🎁 Giv Item</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptGiveWeapon(${p.id}, '${p.charName}', 'weapon_combatpistol')">🔫 Giv Våben</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptSetJob(${p.id}, '${p.charName}')">👔 Sæt Job</button>
                
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: #f97316;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'setFire' })">🔥 Ild</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: #ef4444;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'explode' })">💥 Eksploder</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'cuff' })">🔗 Håndjern</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'drunk' })">🥴 Fuld</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'flashbang' })">⚡ Flashbang</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'slap' }); App.showToast('💥 Slappede ' + '${p.charName}', 'info')">💥 Slap</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptSetGang(${p.id}, '${p.charName}')">🔫 Sæt Bande</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptSetBucket(${p.id}, '${p.charName}')">🌐 Dimension</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-orange);" onclick="App.promptWarnPlayer(${p.id}, '${p.charName}')">⚠️ Advar</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-red);" onclick="API.post('adminPlayerAction', { targetSrc: ${p.id}, action: 'kill' })">💀 Kill</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-red);" onclick="App.promptKickPlayer(${p.id}, '${p.charName}')">👢 Kick</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-red);" onclick="App.promptBanPlayer(${p.id}, '${p.charName}')">🔨 Ban</button>
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

            <!-- TAB 3: ⚡ EGEN KARAKTER -->
      ${tab === 'self' ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">⚡ Egen Karakter &amp; Staff Mode</div>
          <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 16px;">Værktøjer til din egen administrator karakter under vagt.</p>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px;">
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'noclip' })">👻 Toggle Noclip (Flyv)</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'godmode' })">🛡️ Toggle Godmode</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'invisible' })">👤 Toggle Usynlighed</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'superRun' })">🏃 Toggle Super Speed</button>

            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'superJump' })">🚀 Toggle Super Jump</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'infiniteAmmo' })">♾️ Toggle Uendelig Ammo</button>
            <button class="sys-btn sys-btn-primary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'tpWaypoint' })">📍 TP til GPS Waypoint</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'reviveSelf' }); App.showToast('💉 Genoplivede dig selv!', 'success')">💉 Genopliv Mig Selv</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'healSelf' }); App.showToast('🩹 Fuld status!', 'success')">🩹 Fuld Liv &amp; Mad/Tørst</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminPlayerAction', { targetSrc: 0, action: 'giveArmor' }); App.showToast('🛡️ 100% Panser!', 'success')">🛡️ 100% Panser Vest</button>
          </div>
        </div>

        <div class="os-card">
          <div class="os-card-title">👁️ Administrator ESP &amp; Udvikler Overlay</div>
          <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 14px;">Aktiver visuelle hjælpemidler og koordinater direkte på din skærm:</p>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px;">
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'names' })">🏷️ Toggle Spiller-Navne ESP</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'blips' })">🗺️ Toggle Kort-Blips ESP</button>
            <button class="sys-btn sys-btn-secondary" style="padding: 12px; font-size: 0.88rem;" onclick="API.post('adminSelfAction', { action: 'coords' })">🧭 Toggle Udvikler Koordinater</button>
          </div>
        </div>
      ` : ''}

            <!-- TAB 4: 🔫 VÅBEN -->
      ${tab === 'weapons' ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">🔫 Våben Arsenal &amp; QBCore Ammunition</div>
          <p style="font-size: 0.82rem; color: var(--text-secondary); margin-bottom: 14px;">Vælg et våben for at åbne skudantal-input eller indtast et custom våben:</p>
          
          <div style="margin-bottom: 14px;">
            <button class="sys-btn sys-btn-primary" style="width: 100%; padding: 12px; font-size: 0.9rem;" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_combatpistol')">
              ➕ Brugerdefineret Våben &amp; Skudantal...
            </button>
          </div>

          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_combatpistol')">🔫 Combat Pistol</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_appistol')">🔫 AP Pistol</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_combatpdw')">🔫 Combat PDW</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_carbinerifle')">🔫 Carbine Rifle</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_specialcarbine')">🔫 Special Carbine</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_heavysniper')">🎯 Heavy Sniper</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_pumpshotgun')">💥 Pump Shotgun</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_stungun')">⚡ Taser</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_bat')">🏏 Baseball Bat</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_knife')">🔪 Jagtkniv</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptGiveWeapon(0, 'Dig Selv', 'weapon_flashlight')">🔦 Lommelygte</button>
          </div>
          <div style="margin-top: 14px; display: flex; gap: 10px;">
            <button class="sys-btn sys-btn-secondary" style="color: var(--sys-red);" onclick="API.post('adminPlayerAction', { targetSrc: 0, action: 'clearWeapons' }); App.showToast('🚫 Fjernede alle våben', 'info')">🚫 Fjern Alle Mine Våben</button>
          </div>
        </div>
      ` : ''}

      <!-- TAB 5: 📍 TELEPORT HUBS -->
      ${tab === 'teleport' ? `
        <div class="os-card">
          <div class="os-card-title">📍 Hurtige Teleport Destinationer</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px; margin-top: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'legion' }); App.showToast('🚀 Teleporterede til Legion Square', 'success')">🏛️ Legion Square (Centrum)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'pillbox' }); App.showToast('🚀 Teleporterede til Pillbox', 'success')">🏥 Pillbox Hospital</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'mrpd' }); App.showToast('🚀 Teleporterede til MRPD', 'success')">👮 MRPD Politistation</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'lsc' }); App.showToast('🚀 Teleporterede til LS Customs', 'success')">🔧 LS Customs (Mekaniker)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'lsia' }); App.showToast('🚀 Teleporterede til LSIA', 'success')">✈️ LSIA Lufthavn</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'sandy' }); App.showToast('🚀 Teleporterede til Sandy Shores', 'success')">🏜️ Sandy Shores Sheriff</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'paleto' }); App.showToast('🚀 Teleporterede til Paleto Bay', 'success')">🌲 Paleto Bay Bank</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminTpHub', { hubKey: 'chiliad' }); App.showToast('🚀 Teleporterede til Mt. Chiliad', 'success')">🏔️ Mount Chiliad Bjergtop</button>
          </div>
        </div>
      ` : ''}

            <!-- TAB 6: 🚗 KØRETØJER -->
      ${tab === 'vehicles' ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">🚗 Spawn Køretøj</div>
          <div style="display: flex; gap: 10px; margin-top: 10px;">
            <input type="text" id="adminVehModel" class="sys-input" placeholder="Indtast modelnavn (f.eks. adder, sultanrs)..." style="flex: 1;">
            <button class="sys-btn sys-btn-primary" onclick="App.adminSpawnVehicle()">🚗 Spawn Bil</button>
          </div>
        </div>

        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">🔧 Avancerede Bil Værktøjer</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(180px, 1fr)); gap: 10px; margin-top: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehicleAction', { action: 'repair' }); App.showToast('🔧 Bil repareret!', 'success')">🔧 Reparer &amp; Vask Bil</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehicleAction', { action: 'tune' }); App.showToast('⚡ Max tuning installeret!', 'success')">⚡ Max Tuning &amp; Turbo</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehicleAction', { action: 'refuel' }); App.showToast('⛽ Fyldte benzin 100%!', 'success')">⛽ Fyld Benzin 100%</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehExtra', { action: 'flip' }); App.showToast('🔄 Bilen blev vendt om', 'info')">🔄 Flip Bil (Vend om)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehExtra', { action: 'godmode' }); App.showToast('🛡️ Bil godmode ændret', 'info')">🛡️ Toggle Bil Godmode</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptChangePlate()">🏷️ Skift Nummerplade</button>
            <button class="sys-btn sys-btn-primary" onclick="API.post('adminVehExtra', { action: 'saveCar' })">💾 Gem i Min Garage (Admin Car)</button>

            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminVehExtra', { action: 'lock' })">🔒 Lås / Lås Op Døre</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.promptChangeVehColor()">🎨 Vælg Bilfarve Preset</button>
            <button class="sys-btn sys-btn-secondary" style="color: var(--sys-red);" onclick="API.post('adminVehicleAction', { action: 'delete' }); App.showToast('🗑️ Bil slettet', 'info')">🗑️ Slet Køretøj</button>
          </div>
        </div>

        <div class="os-card">
          <div class="os-card-title">🔍 Slå Nummerplade op i Databasen</div>
          <div style="display: flex; gap: 10px; margin-top: 10px;">
            <input type="text" id="adminPlateSearch" class="sys-input" placeholder="Indtast nummerplade..." style="flex: 1;">
            <button class="sys-btn sys-btn-secondary" onclick="App.adminSearchPlate()">🔍 Søg Ejer</button>
          </div>
          ${searchMatches.length > 0 ? `
            <div style="margin-top: 14px;">
              ${searchMatches.map(m => `
                <div class="job-item-card" style="margin-bottom: 8px;">
                  <div>
                    <strong>${m.plate}</strong> · ${m.vehicle} | Ejer: <strong>${m.owner_name || m.citizenid}</strong> (Garage: ${m.garage})
                  </div>
                </div>
              `).join('')}
            </div>
          ` : ''}
        </div>
      ` : ''}

            <!-- TAB 7: 🌍 VERDEN & VEJR -->
      ${tab === 'world' ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">🧹 Ryd Område (Clear Area Værktøjer)</div>
          <p style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 2px; margin-bottom: 12px;">Fjern forladte enheder, NPC'er og props i 100 meters radius:</p>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'clearAreaVehicles', val1: 100 })">🚗 Slet Tomme Biler (100m)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'clearAreaPeds', val1: 100 })">🚶 Slet NPC Peds (100m)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'clearAreaObjects', val1: 100 })">📦 Slet Props &amp; Objekter (100m)</button>
          </div>
        </div>

        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">🌦️ Vejrkontrol &amp; Atmosfære</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr)); gap: 10px; margin-top: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'EXTRASUNNY' }); App.showToast('☀️ Skiftede vejr til Solrigt', 'success')">☀️ Solrigt</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'CLEAR' }); App.showToast('🌤️ Skiftede vejr til Klart', 'success')">🌤️ Klart</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'CLOUDS' }); App.showToast('☁️ Skiftede vejr til Skyet', 'success')">☁️ Skyet</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'OVERCAST' }); App.showToast('🌥️ Skiftede vejr til Overskyet', 'success')">🌥️ Overskyet</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'FOGGY' }); App.showToast('🌫️ Skiftede vejr til Tåget', 'success')">🌫️ Tåge</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'RAIN' }); App.showToast('🌧️ Skiftede vejr til Regn', 'success')">🌧️ Regn</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'THUNDER' }); App.showToast('⛈️ Skiftede vejr til Tordenvejr', 'success')">⛈️ Torden</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setWeather', val1: 'SNOW' }); App.showToast('❄️ Skiftede vejr til Sne', 'success')">❄️ Sne</button>
          </div>
        </div>

        <div class="os-card" style="margin-bottom: 16px;">
          <div class="os-card-title">⏰ Tidskontrol</div>
          <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 10px; margin-top: 10px;">
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setTime', val1: 8, val2: 0 }); App.showToast('🌅 Tiden sat til 08:00', 'success')">🌅 Morgen (08:00)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setTime', val1: 12, val2: 0 }); App.showToast('☀️ Tiden sat til 12:00', 'success')">☀️ Middag (12:00)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setTime', val1: 20, val2: 0 }); App.showToast('🌆 Tiden sat til 20:00', 'success')">🌆 Aften (20:00)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'setTime', val1: 0, val2: 0 }); App.showToast('🌙 Tiden sat til 00:00', 'success')">🌙 Nat (00:00)</button>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminServerAction', { action: 'freezeTime' })">⏱️ Frys Tiden</button>
          </div>
        </div>

        <div class="os-card">
          <div class="os-card-title">⚡ Strømafbrydelse (Blackout)</div>
          <p style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 2px;">Slukker al gadebelysning og elektricitet i hele staten.</p>
          <button class="sys-btn sys-btn-primary" style="margin-top: 10px;" onclick="API.post('adminServerAction', { action: 'toggleBlackout' })">💥 Toggle By-Blackout</button>
        </div>
      ` : ''}

      <!-- TAB 8: 📋 RAPPORTER -->
      ${tab === 'reports' ? `
        <div class="os-card">
          <div class="os-card-title">📋 Aktive Rapporter (${reports.length})</div>
          ${reports.length === 0 ? '<div style="padding: 24px; text-align: center; color: var(--text-muted); font-size: 0.85rem;">Ingen åbne sager i øjeblikket.</div>' : ''}
          ${reports.map(r => `
            <div class="job-item-card" style="margin-bottom: 12px; flex-direction: column; align-items: flex-start;">
              <div style="display: flex; justify-content: space-between; width: 100%;">
                <span style="font-weight: 700; color: #fff;">#${r.id} · ${r.type} (${r.senderName})</span>
                <span class="badge" style="background: rgba(245, 158, 11, 0.15); color: var(--sys-orange);">${r.status}</span>
              </div>
              <p style="font-size: 0.82rem; color: var(--text-secondary); margin: 6px 0;">${r.message}</p>
              <div style="display: flex; gap: 8px; width: 100%; margin-top: 6px;">
                <button class="sys-btn sys-btn-secondary" onclick="API.post('actionReport', { id: ${r.id}, action: 'claim' }); App.showToast('Du har påtaget dig sagen', 'info')">🙋 Påtag Sag</button>
                <button class="sys-btn sys-btn-secondary" onclick="API.post('actionReport', { id: ${r.id}, action: 'teleport' })">🚀 TP til Spiller</button>
                <button class="sys-btn sys-btn-primary" onclick="API.post('actionReport', { id: ${r.id}, action: 'resolve' }); App.showToast('Sagen er løst', 'success')">✅ Marker Løst</button>
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

      
      <!-- TAB 11: 🔨 BANS LISTE -->
      ${tab === 'bans' ? `
        <div class="os-card">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
            <div class="os-card-title">🔨 Aktive Bans i Databasen (${bansList.length})</div>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('adminGetBans')">🔄 Opdater Bans</button>
          </div>
          ${bansList.length === 0 ? '<div style="padding: 24px; text-align: center; color: var(--text-muted); font-size: 0.85rem;">Ingen aktive bans i databasen.</div>' : ''}
          ${bansList.map(b => `
            <div class="job-item-card" style="margin-bottom: 10px; flex-direction: column; align-items: flex-start; gap: 8px;">
              <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                <div>
                  <strong style="color: #fff; font-size: 1rem;">${b.name || 'Spiller'}</strong>
                  <span style="font-size: 0.76rem; color: var(--text-muted); margin-left: 6px;">(Ban #${b.id})</span>
                </div>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-green);" onclick="API.post('adminUnban', { id: ${b.id} }); App.showToast('✅ Ophævede ban #' + ${b.id}, 'success')">🔓 Unban</button>
              </div>
              <div style="font-size: 0.82rem; color: var(--text-secondary);">
                Årsag: <span style="color: #fca5a5;">${b.reason || 'Ingen årsag angivet'}</span>
              </div>
              <div style="font-size: 0.74rem; color: var(--text-muted); font-family: var(--font-mono);">
                Udelukket af: ${b.banned_by || 'Staff'} · Licens: ${b.license || 'N/A'}
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

      <!-- TAB 9: 🛡️ STAFF MEDLEMMER -->
      ${tab === 'staff' ? `
        <div class="os-card" style="margin-bottom: 16px;">
          <div style="display: flex; justify-content: space-between; align-items: center;">
            <div>
              <div class="os-card-title">🛡️ Opret / Tilføj Nyt Staff Medlem</div>
              <p style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 2px;">Tildel in-game administrationsrettigheder.</p>
            </div>
            <button class="sys-btn sys-btn-primary" onclick="App.promptAddStaff()">+ Opret Staff Medlem</button>
          </div>
        </div>

        <div class="os-card">
          <div class="os-card-title">👥 Nuværende Staff Medlemmer (${staffList.length})</div>
          ${staffList.length === 0 ? '<div style="padding:20px; text-align:center; color:var(--text-muted);">Ingen staff medlemmer i databasen endnu.</div>' : ''}
          ${staffList.map(sm => `
            <div class="job-item-card" style="margin-bottom: 10px;">
              <div style="flex: 1;">
                <div style="display: flex; align-items: center; gap: 8px;">
                  <span style="font-weight: 800; color: #fff; font-size: 1rem;">${sm.name}</span>
                  <span class="badge" style="background: rgba(59,130,246,0.2); color: #60a5fa; font-weight: 700;">${sm.rank.toUpperCase()}</span>
                </div>
                <div style="font-size: 0.76rem; color: var(--text-secondary); margin-top: 4px; font-family: var(--font-mono);">
                  ID: ${sm.identifier} · Tilføjet af: ${sm.added_by}
                </div>
              </div>
              <div style="display: flex; gap: 8px;">
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="App.promptChangeStaffRank(${sm.id}, '${sm.name}')">👔 Skift Rang</button>
                <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-red);" onclick="App.confirmRemoveStaff(${sm.id}, '${sm.name}')">🗑️ Fjern</button>
              </div>
            </div>
          `).join('')}
        </div>
      ` : ''}

      <!-- TAB 10: 📜 REVISIONSLOG -->
      ${tab === 'audit' ? `
        <div class="os-card">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <div>
              <div class="os-card-title">📜 Revisionslog &amp; Telemetri (${auditLogs.length})</div>
              <p style="font-size: 0.78rem; color: var(--text-secondary);">Alle administrative handlinger logget med tidspunkt og parametre.</p>
            </div>
            <div style="display: flex; gap: 8px;">
              <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px;" onclick="API.post('adminGetAuditLogs')">🔄 Opdater Log</button>
              <button class="sys-btn sys-btn-secondary" style="font-size: 0.75rem; padding: 4px 10px; color: var(--sys-red);" onclick="App.confirmClearAuditLogs()">🧹 Ryd Log</button>
            </div>
          </div>
          ${auditLogs.length === 0 ? '<div style="padding: 24px; text-align: center; color: var(--text-muted); font-size: 0.85rem;">Ingen loggede handlinger endnu.</div>' : ''}
          <div style="display: flex; flex-direction: column; gap: 8px; max-height: 440px; overflow-y: auto;">
            ${auditLogs.map(log => `
              <div class="job-item-card" style="margin-bottom: 0; padding: 10px 14px; flex-direction: column; align-items: flex-start; gap: 4px;">
                <div style="display: flex; justify-content: space-between; width: 100%; align-items: center;">
                  <div style="display: flex; align-items: center; gap: 8px;">
                    <span class="badge" style="background: rgba(59,130,246,0.15); color: #60a5fa; font-weight: 800; font-family: var(--font-mono); font-size: 0.74rem;">${log.action}</span>
                    <strong style="color: #fff; font-size: 0.86rem;">${log.staff_name || 'Staff'}</strong>
                    <span style="font-size: 0.75rem; color: var(--text-muted);">(ID: ${log.staff_id})</span>
                  </div>
                  <span style="font-size: 0.72rem; color: var(--text-muted); font-family: var(--font-mono);">${log.created_at || ''}</span>
                </div>
                <div style="font-size: 0.78rem; color: var(--text-secondary); font-family: var(--font-mono); word-break: break-all;">
                  Detaljer: ${log.details || '{}'}
                </div>
              </div>
            `).join('')}
          </div>
        </div>
      ` : ''}
    `;
  }
};

if (typeof window !== 'undefined') window.Renderers = Renderers;

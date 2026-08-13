// ============================================================
// MTNC TABLET OS v3.0.2 — COMPLETE 14 APPLICATION RENDERERS (i18n READY)
// ============================================================

function getAppsList() {
  return [
    { id: 'profile', name: t('app_profile'), icon: '👤', desc: t('app_profile_desc'), isStaffOnly: false },
    { id: 'jobs', name: t('app_jobs'), icon: '💼', desc: t('app_jobs_desc'), isStaffOnly: false },
    { id: 'camera', name: t('app_camera'), icon: '📷', desc: t('app_camera_desc'), isStaffOnly: false },
    { id: 'photos', name: t('app_photos'), icon: '🖼️', desc: t('app_photos_desc'), isStaffOnly: false },
    { id: 'phone', name: t('app_phone'), icon: '📱', desc: t('app_phone_desc'), isStaffOnly: false },
    { id: 'vehicles', name: t('app_vehicles'), icon: '🚗', desc: t('app_vehicles_desc'), isStaffOnly: false },
    { id: 'housing', name: t('app_housing'), icon: '🏠', desc: t('app_housing_desc'), isStaffOnly: false },
    { id: 'reports', name: t('app_reports'), icon: '📋', desc: t('app_reports_desc'), isStaffOnly: false },
    { id: 'settings', name: t('app_settings'), icon: '⚙️', desc: t('app_settings_desc'), isStaffOnly: false },
    { id: 'updates', name: t('app_updates'), icon: '📰', desc: t('app_updates_desc'), isStaffOnly: false },
    { id: 'about', name: t('app_about'), icon: 'ℹ️', desc: t('app_about_desc'), isStaffOnly: false },
    { id: 'admin', name: t('app_admin'), icon: '🛡️', desc: t('app_admin_desc'), isStaffOnly: true }
  ];
}

const Renderers = {
  profile(state) {
    const s = state.session || {};
    const p = state.profile || {};
    const job = p.primaryJob || { label: 'Arbejdsløs', gradeLabel: 'Borger', duty: false };

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('profile_title')}</h2>
            <p class="app-heading-sub">${t('profile_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">${t('profile_id_card')}</div>
          <div class="os-card-row"><span class="row-label">${t('profile_fullname')}</span><span class="row-value">${p.name || 'Thomas'}</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_serverid')}</span><span class="row-value">#${p.serverId || 1}</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_primary_job')}</span><span class="row-value">${job.label}</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_grade')}</span><span class="row-value">${job.gradeLabel}</span></div>
          <div class="os-card-row"><span class="row-label">${t('dutyStatus')}</span><span class="row-value" style="color:${job.duty ? 'var(--sys-green)' : 'var(--text-muted)'};">${job.duty ? t('onDuty') : t('offDuty')}</span></div>
        </div>

        <div class="os-card">
          <div class="os-card-title">📱 ${t('profile_phone')}</div>
          <div class="os-card-row"><span class="row-label">${t('profile_phone')}</span><span class="row-value">${p.phone || '+45 XXXXXXXX'}</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_system_role')}</span><span class="row-value">${s.role || 'Bruger'}</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_gateway')}</span><span class="row-value" style="color:var(--sys-green);">${t('connected')} (Cloud Sikret)</span></div>
          <div class="os-card-row"><span class="row-label">${t('profile_license_status')}</span><span class="row-value">${t('profile_sec_status')}</span></div>
        </div>
      </div>
    `;
  },

  jobs(state) {
    const jobsData = state.jobsData || { primary: { name: 'unemployed', label: 'Arbejdsløs', gradeLabel: 'Borger', duty: false, salary: 0 }, jobs: [] };
    const p = jobsData.primary;
    const others = (jobsData.jobs || []).filter(j => j.name !== p.name);

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('jobs_title')}</h2>
            <p class="app-heading-sub">${t('jobs_sub')}</p>
          </div>
        </div>
        <button class="sys-btn sys-btn-blue" onclick="API.post('toggleDuty')">
          ${p.duty ? t('goOffDuty') : t('goOnDuty')}
        </button>
      </div>

      <div class="os-card" style="margin-bottom: 20px;">
        <div class="os-card-title">${t('jobs_primary')}</div>
        <div class="job-item-card is-primary">
          <div>
            <div style="font-size: 1.15rem; font-weight: 800; color: #fff;">${p.label}</div>
            <div style="font-size: 0.82rem; color: var(--text-secondary); margin-top: 2px;">
              ${p.gradeLabel} · ${t('jobs_salary')}: $${p.salary || 0}
            </div>
          </div>
          <div>
            <span class="row-value" style="color:${p.duty ? 'var(--sys-green)' : 'var(--text-muted)'}; font-weight: 700;">
              ${p.duty ? t('onDutyShort') : t('offDutyShort')}
            </span>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">${t('jobs_others')}</div>
        ${others.length === 0 ? `<p style="color:var(--text-muted); font-size:0.85rem;">${t('jobs_no_others')}</p>` : ''}
        ${others.map(j => `
          <div class="job-item-card">
            <div>
              <div style="font-size: 0.95rem; font-weight: 700; color: #fff;">${j.label}</div>
              <div style="font-size: 0.78rem; color: var(--text-secondary);">${j.gradeLabel} · ${t('jobs_salary')}: $${j.salary || 0}</div>
            </div>
            <button class="sys-btn sys-btn-secondary" onclick="API.post('switchJob', { jobName: '${j.name}', grade: ${j.grade || 0} })">
              ${t('jobs_switch')}
            </button>
          </div>
        `).join('')}
      </div>
    `;
  },

  camera() {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('camera_title')}</h2>
            <p class="app-heading-sub">${t('camera_sub')}</p>
          </div>
        </div>
      </div>

      <div class="camera-viewfinder-box">
        <div class="viewfinder-grid-lines">
          <div></div><div></div><div></div>
          <div></div><div></div><div></div>
          <div></div><div></div><div></div>
        </div>
        <div style="color: var(--text-muted); font-size: 0.88rem; z-index: 10;">${t('camera_viewfinder')}</div>
        <button class="camera-shutter-trigger" onclick="App.triggerShutter()"></button>
      </div>
    `;
  },

  photos(state) {
    const photos = state.photos || [];
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('photos_title')}</h2>
            <p class="app-heading-sub">${t('photos_sub')}</p>
          </div>
        </div>
      </div>

      <div class="photo-gallery-grid">
        ${photos.length === 0 ? `<p style="color:var(--text-muted); font-size:0.85rem; grid-column: span 4;">${t('photos_empty')}</p>` : ''}
        ${photos.map(p => `
          <div class="photo-thumb-card" title="${p.location} · ${p.date}">
            <img src="${p.image}" alt="Snapshot">
          </div>
        `).join('')}
      </div>
    `;
  },

  phone(state) {
    const phone = state.profile?.phone || '+45 88992211';
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('phone_title')}</h2>
            <p class="app-heading-sub">${t('phone_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">${t('phone_device_info')}</div>
          <div class="os-card-row"><span class="row-label">${t('phone_number')}</span><span class="row-value">${phone}</span></div>
          <div class="os-card-row"><span class="row-label">${t('phone_integration')}</span><span class="row-value">LB Phone (Aktiv)</span></div>
          <div class="os-card-row"><span class="row-label">${t('phone_pin_status')}</span><span class="row-value">${t('phone_pin_locked')}</span></div>
        </div>

        <div class="os-card">
          <div class="os-card-title">${t('phone_reset_card')}</div>
          <p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 14px; line-height: 1.4;">
            ${t('phone_reset_desc')}
          </p>
          <input type="text" id="pin-reset-reason" class="sys-input" placeholder="${t('phone_reset_placeholder')}" style="margin-bottom: 12px;">
          <button class="sys-btn sys-btn-blue" style="width: 100%;" onclick="App.submitPinReset()">${t('phone_reset_btn')}</button>
        </div>
      </div>
    `;
  },

  vehicles() {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('vehicles_title')}</h2>
            <p class="app-heading-sub">${t('vehicles_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">${t('vehicles_card_title')}</div>
        <div class="job-item-card">
          <div>
            <div style="font-size: 1rem; font-weight: 700; color: #fff;">Pfister Comet S2 (Plade: MTNC 88)</div>
            <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 2px;">
              Garage: Legion Square · Benzin: 92% · Motor: 100% · Tilstand: God
            </div>
          </div>
          <button class="sys-btn sys-btn-secondary" onclick="App.showToast('📍 GPS waypoint sat!', 'success')">
            ${t('vehicles_gps_btn')}
          </button>
        </div>
      </div>
    `;
  },

  housing() {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('housing_title')}</h2>
            <p class="app-heading-sub">${t('housing_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">${t('housing_card_title')}</div>
        <div class="job-item-card">
          <div>
            <div style="font-size: 1rem; font-weight: 700; color: #fff;">Lejlighed #402 (Vinewood Hills)</div>
            <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 2px;">
              Nøgler: 2 udstedt · Garagepladser: 4 biler · Status: Låst
            </div>
          </div>
          <button class="sys-btn sys-btn-secondary" onclick="App.showToast('📍 GPS waypoint sat!', 'success')">
            ${t('housing_gps_btn')}
          </button>
        </div>
      </div>
    `;
  },

  reports(state) {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('reports_title')}</h2>
            <p class="app-heading-sub">${t('reports_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">${t('reports_create_title')}</div>
          <form onsubmit="App.submitReport(event)">
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">${t('reports_category')}</label>
            <select id="rep-category" class="sys-select" style="margin-bottom:10px;">
              <option>Spiller Report</option>
              <option>Bug / Teknisk Fejl</option>
              <option>Spørgsmål til Staff</option>
            </select>
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">${t('reports_target')}</label>
            <input type="number" id="rep-target" class="sys-input" placeholder="F.eks. 42" style="margin-bottom:10px;">
            <label style="font-size:0.75rem; color:var(--text-muted); display:block; margin-bottom:4px;">${t('reports_desc')}</label>
            <textarea id="rep-reason" required class="sys-textarea" rows="3" placeholder="Beskriv hændelsen så præcist som muligt..." style="margin-bottom:14px;"></textarea>
            <button type="submit" class="sys-btn sys-btn-blue" style="width:100%;">${t('reports_submit')}</button>
          </form>
        </div>

        <div class="os-card">
          <div class="os-card-title">${t('reports_info_title')}</div>
          <p style="font-size:0.82rem; color:var(--text-secondary); line-height:1.5;">
            ${t('reports_info_text')}
          </p>
        </div>
      </div>
    `;
  },

  // ⚙️ 9. Settings App with Live Language Switcher!
  settings() {
    const curLang = localStorage.getItem('mtnc_tablet_lang') || 'da';
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('settings_title')}</h2>
            <p class="app-heading-sub">${t('settings_sub')}</p>
          </div>
        </div>
      </div>

      <!-- Language Selection Card -->
      <div class="os-card" style="margin-bottom: 20px;">
        <div class="os-card-title">${t('settings_lang_title')}</div>
        <p style="font-size:0.82rem; color:var(--text-secondary); margin-bottom:14px;">${t('settings_lang_sub')}</p>
        <div style="display:flex; gap:10px; flex-wrap:wrap;">
          ${Object.entries(Locales).map(([code, data]) => `
            <button class="sys-btn ${curLang === code ? 'sys-btn-blue' : 'sys-btn-secondary'}" onclick="App.setLanguage('${code}')" style="padding:10px 20px;">
              ${data.flag} ${data.name}
            </button>
          `).join('')}
        </div>
      </div>

      <div class="os-grid-2">
        <div class="os-card">
          <div class="os-card-title">${t('settings_display_title')}</div>
          <div class="os-card-row"><span class="row-label">${t('settings_theme_label')}</span><span class="row-value">Titanium Mørk (Standard)</span></div>
          <div class="os-card-row"><span class="row-label">${t('settings_scale_label')}</span><span class="row-value">100%</span></div>
        </div>

        <div class="os-card">
          <div class="os-card-title">${t('settings_sound_title')}</div>
          <div class="os-card-row"><span class="row-label">${t('settings_keyclick')}</span><span class="row-value">${t('settings_enabled')}</span></div>
          <div class="os-card-row"><span class="row-label">${t('settings_chime')}</span><span class="row-value">Standard Chime</span></div>
        </div>
      </div>
    `;
  },

  updates(state) {
    const up = state.updates || { installed: '3.0.2', latest: '3.0.2', hasUpdate: false, body: 'Systemet er fuldt opdateret.' };
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('updates_title')}</h2>
            <p class="app-heading-sub">${t('updates_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">${t('updates_version_title')}</div>
        <div class="os-card-row"><span class="row-label">${t('updates_installed')}</span><span class="row-value">${up.installed}</span></div>
        <div class="os-card-row"><span class="row-label">${t('updates_latest')}</span><span class="row-value">${up.latest}</span></div>
        <div class="os-card-row"><span class="row-label">${t('updates_status')}</span><span class="row-value" style="color:${up.hasUpdate ? 'var(--sys-orange)' : 'var(--sys-green)'}; font-weight:700;">${up.hasUpdate ? t('updates_available') : t('updates_uptodate')}</span></div>
      </div>
    `;
  },

  about() {
    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('about_title')}</h2>
            <p class="app-heading-sub">${t('about_sub')}</p>
          </div>
        </div>
      </div>

      <div class="os-card">
        <div class="os-card-title">${t('about_card_title')}</div>
        <p style="font-size:0.86rem; color:var(--text-secondary); line-height:1.6; margin-bottom:16px;">
          Udviklet af <strong>NovaCore × MTCore</strong> · Udviklet af MrWolfDk &amp; MrGuld.<br>
          © 2026 Alle rettigheder forbeholdes.
        </p>
        <div class="os-card-row"><span class="row-label">${t('about_build')}</span><span class="row-value">v3.0.2-PROD</span></div>
        <div class="os-card-row"><span class="row-label">${t('about_license')}</span><span class="row-value" style="color:var(--sys-green);">${t('about_license_val')}</span></div>
      </div>
    `;
  },

  admin(state) {
    const s = state.session || {};
    const pinReqs = state.pinRequests || [];
    const reps = state.reports || [];

    return `
      <div class="os-app-header">
        <div class="app-nav-group">
          <button class="nav-back-btn" onclick="App.openApp('home')">←</button>
          <div>
            <h2 class="app-heading-title">${t('admin_title')}</h2>
            <p class="app-heading-sub">${t('admin_sub')}: ${s.name || 'Staff'} (${s.role || 'SUPERADMIN'})</p>
          </div>
        </div>
      </div>

      <div class="admin-tab-bar">
        <button class="admin-nav-tab active" onclick="App.switchAdminTab('dash')">${t('admin_tab_dash')}</button>
        <button class="admin-nav-tab" onclick="App.switchAdminTab('players')">${t('admin_tab_players')}</button>
        <button class="admin-nav-tab" onclick="App.switchAdminTab('reports')">${t('admin_tab_reports')} (${reps.length})</button>
        <button class="admin-nav-tab" onclick="App.switchAdminTab('pin')">${t('admin_tab_pin')} (${pinReqs.filter(r=>r.status==='PENDING').length})</button>
      </div>

      <div id="admin-tab-dash">
        <div class="os-grid-3" style="margin-bottom: 20px;">
          <div class="os-card"><div class="os-card-title">${t('admin_gateway')}</div><div style="font-size:1.6rem; font-weight:800; color:var(--sys-green);">ONLINE</div></div>
          <div class="os-card"><div class="os-card-title">${t('admin_open_reports')}</div><div style="font-size:1.6rem; font-weight:800; color:var(--sys-blue);">${reps.filter(r=>r.status==='OPEN').length}</div></div>
          <div class="os-card"><div class="os-card-title">${t('admin_pin_reqs')}</div><div style="font-size:1.6rem; font-weight:800; color:var(--sys-orange);">${pinReqs.filter(r=>r.status==='PENDING').length}</div></div>
        </div>
      </div>

      <div id="admin-tab-players" style="display:none;">
        <div class="os-card">
          <div class="os-card-title">${t('admin_player_actions')}</div>
          <input type="number" id="admin-target-id" class="sys-input" placeholder="${t('admin_target_placeholder')}" style="margin-bottom:14px;">
          <div style="display: flex; gap: 8px; flex-wrap: wrap;">
            <button class="sys-btn sys-btn-secondary" onclick="App.adminAction('freeze')">${t('admin_freeze')}</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.adminAction('teleport')">${t('admin_teleport')}</button>
            <button class="sys-btn sys-btn-secondary" onclick="App.adminAction('bring')">${t('admin_bring')}</button>
            <button class="sys-btn sys-btn-danger" onclick="App.adminAction('kick')">${t('admin_kick')}</button>
          </div>
        </div>
      </div>

      <div id="admin-tab-reports" style="display:none;">
        <div class="os-card">
          <div class="os-card-title">${t('admin_tab_reports')}</div>
          ${reps.length === 0 ? '<p style="color:var(--text-muted); font-size:0.85rem;">Ingen aktive rapporter.</p>' : ''}
          ${reps.map(r => `
            <div class="job-item-card">
              <div>
                <div style="font-weight:700; color:#fff;">Report #${r.id} · ${r.authorName} (ID: #${r.authorSrc})</div>
                <div style="font-size:0.78rem; color:var(--text-secondary);">${r.category}: ${r.reason} · Status: ${r.status}</div>
              </div>
              <div style="display:flex; gap:6px;">
                ${r.status === 'OPEN' ? `<button class="sys-btn sys-btn-secondary" onclick="API.post('actionReport', { id: ${r.id}, action: 'claim' })">${t('admin_claim')}</button>` : ''}
                ${r.status !== 'CLOSED' ? `<button class="sys-btn sys-btn-danger" onclick="API.post('actionReport', { id: ${r.id}, action: 'close' })">${t('admin_close')}</button>` : ''}
              </div>
            </div>
          `).join('')}
        </div>
      </div>

      <div id="admin-tab-pin" style="display:none;">
        <div class="os-card">
          <div class="os-card-title">${t('admin_tab_pin')}</div>
          ${pinReqs.length === 0 ? '<p style="color:var(--text-muted); font-size:0.85rem;">Ingen ventende PIN-nulstillinger.</p>' : ''}
          ${pinReqs.map(req => `
            <div class="job-item-card">
              <div>
                <div style="font-weight:700; color:#fff;">${req.name} (Tlf: ${req.phone})</div>
                <div style="font-size:0.78rem; color:var(--text-secondary);">Årsag: ${req.reason} · Status: ${req.status}</div>
              </div>
              ${req.status === 'PENDING' ? `
                <div style="display:flex; gap:6px;">
                  <button class="sys-btn sys-btn-blue" onclick="API.post('handlePinRequest', { id: ${req.id}, approve: true })">${t('admin_approve')}</button>
                  <button class="sys-btn sys-btn-danger" onclick="API.post('handlePinRequest', { id: ${req.id}, approve: false })">${t('admin_deny')}</button>
                </div>
              ` : `<span class="row-value">${req.status}</span>`}
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }
};

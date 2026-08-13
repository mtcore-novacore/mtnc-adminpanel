// ============================================================
// MTNC TABLET OS v3.0.2 — MAIN CONTROLLER & RUNTIME
// ============================================================
const App = {
  state: {
    isOpen: false,
    currentApp: 'home',
    session: { isStaff: false },
    profile: {},
    jobsData: null,
    photos: [],
    reports: [],
    pinRequests: [],
    updates: null,
    notifications: []
  },

  init() {
    this.startClock();
    this.setupEventListeners();
    this.renderAppGrid();
    this.updateStaticLabels();
  },

  startClock() {
    const updateTime = () => {
      const now = new Date();
      const hours = String(now.getHours()).padStart(2, '0');
      const mins = String(now.getMinutes()).padStart(2, '0');
      const timeStr = `${hours}:${mins}`;
      const clockEl = document.getElementById('os-clock');
      const homeClockEl = document.getElementById('home-time');
      if (clockEl) clockEl.textContent = timeStr;
      if (homeClockEl) homeClockEl.textContent = timeStr;
    };
    updateTime();
    setInterval(updateTime, 1000);
  },

  setLanguage(langCode) {
    if (!Locales[langCode]) return;
    localStorage.setItem('mtnc_tablet_lang', langCode);
    this.renderAppGrid();
    this.renderCurrentView();
    this.updateStaticLabels();
    this.showToast(`🌐 Sprog skiftet til ${Locales[langCode].name}!`, 'success');
  },

  updateStaticLabels() {
    const elSystem = document.getElementById('lbl-system-status');
    const elGateway = document.getElementById('lbl-gateway-status');
    const elChar = document.getElementById('lbl-char');
    const elActiveJob = document.getElementById('lbl-active-job');
    const elDutyStatus = document.getElementById('lbl-duty-status');
    const elHomeIndicator = document.getElementById('home-indicator');

    if (elSystem) elSystem.textContent = t('systemStatus');
    if (elGateway) elGateway.textContent = t('connected');
    if (elChar) elChar.textContent = t('character');
    if (elActiveJob) elActiveJob.textContent = t('activeJob');
    if (elDutyStatus) elDutyStatus.textContent = t('dutyStatus');
    if (elHomeIndicator) elHomeIndicator.title = t('closeTablet');
  },

  setupEventListeners() {
    window.addEventListener('message', (event) => {
      const { action, data, open, msg, toastType } = event.data;
      if (action === 'toggleTablet') {
        this.toggle(open);
      } else if (action === 'initTablet') {
        this.state.session = data.session || {};
        this.state.profile = data.profile || {};
        
        // Update Home widgets
        const charNameEl = document.getElementById('widget-char-name');
        const charJobEl = document.getElementById('widget-char-job');
        const dutyEl = document.getElementById('widget-duty-status');
        if (charNameEl) charNameEl.textContent = this.state.profile.name || 'Thomas';
        if (charJobEl && this.state.profile.primaryJob) {
          charJobEl.textContent = `${this.state.profile.primaryJob.label} · ${this.state.profile.primaryJob.gradeLabel}`;
        }
        if (dutyEl && this.state.profile.primaryJob) {
          dutyEl.textContent = this.state.profile.primaryJob.duty ? t('onDutyShort') : t('offDutyShort');
        }

        this.renderAppGrid();
        this.renderCurrentView();
      } else if (action === 'setVehicles') {
        this.state.vehicles = data || [];
        if (this.state.currentApp === 'vehicles') this.renderCurrentView();
      } else if (action === 'setJobs') {
        this.state.jobsData = data;
        if (this.state.currentApp === 'jobs') this.renderCurrentView();
      } else if (action === 'setPhotos') {
        this.state.photos = data || [];
        if (this.state.currentApp === 'photos') this.renderCurrentView();
      } else if (action === 'setReports') {
        this.state.reports = data || [];
        if (this.state.currentApp === 'reports' || this.state.currentApp === 'admin') this.renderCurrentView();
      } else if (action === 'setAdminStaffList') {
        this.state.adminStaff = data || [];
        if (this.state.currentApp === 'admin') this.renderCurrentView();
      } else if (action === 'setAdminPlayers') {
        this.state.adminPlayers = data || [];
        if (this.state.currentApp === 'admin') this.renderCurrentView();
      } else if (action === 'setAdminVehicleSearch') {
        this.state.adminVehMatches = data || [];
        if (this.state.currentApp === 'admin') this.renderCurrentView();
      } else if (action === 'setPinRequests') {
        this.state.pinRequests = data || [];
        if (this.state.currentApp === 'admin') this.renderCurrentView();
      } else if (action === 'setUpdates') {
        this.state.updates = data || null;
        if (this.state.currentApp === 'updates') this.renderCurrentView();
      } else if (action === 'toast') {
        this.showToast(msg, toastType);
      }
    });

    window.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close();
      }
    });

    document.getElementById('home-indicator')?.addEventListener('click', () => this.close());
    document.querySelectorAll('.dock-app-icon').forEach(btn => {
      btn.addEventListener('click', () => this.openApp(btn.dataset.open));
    });
  },

  toggle(state) {
    this.state.isOpen = state !== undefined ? state : !this.state.isOpen;
    const container = document.getElementById('tablet-container');
    if (container) {
      if (this.state.isOpen) {
        container.classList.remove('hidden');
        this.openApp('home');
      } else {
        container.classList.add('hidden');
      }
    }
  },

  close() {
    this.toggle(false);
    API.post('closeTablet');
  },

  
  setAdminTab(tabName) {
    this.state.adminTab = tabName;
    if (tabName === 'players') API.post('adminGetPlayers');
    if (tabName === 'staff') API.post('adminGetStaffList');
    this.renderCurrentView();
  },

  refreshAdminData() {
    API.post('adminGetPlayers');
    API.post('getReports');
    API.post('getPinRequests');
    this.showToast('Opdaterer admin data...', 'info');
  },

  
  promptAddStaff() {
    const ident = prompt('Indtast Spiller Identifier (f.eks. discord:123456, fivem:4866650 eller license:...):');
    if (!ident || !ident.trim()) return;
    const name = prompt('Indtast Staff Navn:') || 'Staff';
    const rank = prompt('Vælg Rang (superadmin, admin, moderator):') || 'moderator';
    API.post('adminAddStaff', { identifier: ident.trim(), name: name.trim(), rank: rank.trim().toLowerCase() });
  },

  promptChangeStaffRank(id, name) {
    const newRank = prompt('Indtast ny rang for ' + name + ' (superadmin, admin, moderator):');
    if (newRank && newRank.trim()) {
      API.post('adminUpdateStaffRank', { id: id, rank: newRank.trim().toLowerCase() });
    }
  },

  confirmRemoveStaff(id, name) {
    if (confirm('Er du sikker på, at du vil fjerne ' + name + ' fra Staff?')) {
      API.post('adminRemoveStaff', { id: id });
    }
  },

  promptAnnounce() {
    const msg = prompt('Indtast servermeddelelse:');
    if (msg && msg.trim()) {
      API.post('adminServerAction', { action: 'announce', val1: msg.trim() });
      this.showToast('📢 Udsendte serverbesked!', 'success');
    }
  },

  promptGiveMoney(targetId, name) {
    const amount = prompt('Indtast beløb der skal gives til ' + name + ':');
    if (amount && parseInt(amount) > 0) {
      API.post('adminPlayerAction', { targetSrc: targetId, action: 'giveMoney', val1: 'cash', val2: parseInt(amount) });
      this.showToast('💰 Gav ' + amount + ' DKK til ' + name, 'success');
    }
  },

  promptSetJob(targetId, name) {
    const job = prompt('Indtast nyt jobnavn for ' + name + ' (f.eks. police, ambulance, mechanic):');
    if (job && job.trim()) {
      const grade = prompt('Indtast job rang/grad (f.eks. 0, 1, 2):') || '0';
      API.post('adminPlayerAction', { targetSrc: targetId, action: 'setJob', val1: job.trim(), val2: parseInt(grade) });
      this.showToast('👔 Satte job for ' + name + ' til ' + job, 'success');
    }
  },

  promptWarnPlayer(targetId, name) {
    const reason = prompt('Indtast advarselsårsag for ' + name + ':');
    if (reason && reason.trim()) {
      API.post('adminPlayerAction', { targetSrc: targetId, action: 'warn', val1: reason.trim() });
      this.showToast('⚠️ Advarsel sendt til ' + name, 'info');
    }
  },

  promptKickPlayer(targetId, name) {
    const reason = prompt('Indtast årsag til kick af ' + name + ':');
    if (reason && reason.trim()) {
      API.post('adminPlayerAction', { targetSrc: targetId, action: 'kick', val1: reason.trim() });
      this.showToast('👢 Kicket ' + name, 'info');
    }
  },

  adminSpawnVehicle() {
    const input = document.getElementById('adminVehModel');
    const model = input && input.value ? input.value.trim() : 'adder';
    API.post('adminVehicleAction', { action: 'spawn', model: model });
    if (input) input.value = '';
  },

  adminSearchPlate() {
    const input = document.getElementById('adminPlateSearch');
    const plate = input && input.value ? input.value.trim() : '';
    if (plate) {
      API.post('adminSearchPlate', { plate: plate });
      this.showToast('Søger efter nummerplade: ' + plate, 'info');
    }
  },

  openApp(appId) {
    this.state.currentApp = appId;
    document.querySelectorAll('.os-view').forEach(view => view.classList.add('hidden'));
    const target = document.getElementById(`view-${appId}`);
    if (target) {
      target.classList.remove('hidden');
      this.renderCurrentView();
    }
    // Fetch live data
    if (appId === 'jobs') API.post('getJobs');
    if (appId === 'vehicles') API.post('getVehicles');
    if (appId === 'photos') API.post('getPhotos');
    if (appId === 'reports') API.post('getReports');
    if (appId === 'admin') {
      API.post('getPinRequests');
      API.post('getReports');
    }
    if (appId === 'updates') API.post('getUpdates');
  },

  renderAppGrid() {
    const grid = document.getElementById('desktop-app-grid');
    if (!grid) return;

    const isStaff = this.state.session?.isStaff || false;
    const appsToShow = getAppsList().filter(a => !a.isStaffOnly || isStaff);

    grid.innerHTML = appsToShow.map(a => `
      <div class="app-icon" onclick="App.openApp('${a.id}')">
        <div class="icon-squircle">${a.icon}</div>
        <span class="icon-title">${a.name}</span>
      </div>
    `).join('');
  },

  renderCurrentView() {
    const appId = this.state.currentApp;
    if (appId === 'home') return;
    const renderer = Renderers[appId];
    const target = document.getElementById(`view-${appId}`);
    if (target && renderer) {
      target.innerHTML = renderer(this.state);
    }
  },

  switchAdminTab(tab) {
    document.querySelectorAll('.admin-nav-tab').forEach(b => b.classList.remove('active'));
    event.target.classList.add('active');
    ['dash', 'players', 'reports', 'pin'].forEach(t => {
      const el = document.getElementById(`admin-tab-${t}`);
      if (el) el.style.display = t === tab ? 'block' : 'none';
    });
  },

  adminAction(action) {
    const targetInput = document.getElementById('admin-target-id');
    const targetId = targetInput ? parseInt(targetInput.value) : null;
    if (!targetId) return this.showToast('Indtast venligst et gyldigt spiller ID', 'warning');
    API.post('adminAction', { targetSrc: targetId, action: action, reason: 'Admin handling via tablet' });
    this.showToast(`Handling '${action}' udført for spiller #${targetId}`, 'info');
  },

  triggerShutter() {
    API.post('capturePhoto', {});
    this.showToast(t('camera_saved'), 'success');
  },

  submitReport(e) {
    e.preventDefault();
    const cat = document.getElementById('rep-category')?.value;
    const target = document.getElementById('rep-target')?.value;
    const reason = document.getElementById('rep-reason')?.value;
    API.post('createReport', { category: cat, targetId: target, reason: reason });
    this.openApp('home');
  },

  submitPinReset() {
    const reason = document.getElementById('pin-reset-reason')?.value;
    if (!reason || !reason.trim()) return this.showToast('Angiv venligst en årsag', 'warning');
    API.post('requestPhonePinReset', { reason: reason.trim() });
    this.openApp('home');
  },

  showToast(msg, type = 'info') {
    const deck = document.getElementById('toast-deck');
    if (!deck) return;
    const bubble = document.createElement('div');
    bubble.className = 'toast-bubble';
    bubble.textContent = msg;
    deck.appendChild(bubble);
    setTimeout(() => {
      bubble.remove();
    }, 4000);
  }
};

document.addEventListener('DOMContentLoaded', () => {
  App.init();
});

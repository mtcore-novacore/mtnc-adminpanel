// ──────────────────────────────────────────────────────
//  MTNC Admin Tablet — NUI JavaScript App v3.0
//  Dual Mode Controller: Player Profile & AdminPanel
// ──────────────────────────────────────────────────────

let onlinePlayersData = [];
let currentUserData = null;

document.addEventListener('DOMContentLoaded', () => {
  const app = document.getElementById('app');
  const closeBtn = document.getElementById('close-btn');
  const tabletClock = document.getElementById('tablet-clock');

  // Mode buttons
  const modeProfileBtn = document.getElementById('mode-profile-btn');
  const modeAdminBtn = document.getElementById('mode-admin-btn');
  const viewProfile = document.getElementById('view-profile');
  const viewAdmin = document.getElementById('view-admin');

  // Update Clock
  setInterval(() => {
    const now = new Date();
    if (tabletClock) {
      tabletClock.innerText = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
  }, 1000);

  // Close button
  if (closeBtn) {
    closeBtn.addEventListener('click', closeTablet);
  }

  // ESC Key to close
  window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      closeTablet();
    }
  });

  // Mode switching
  if (modeProfileBtn) {
    modeProfileBtn.addEventListener('click', () => {
      modeProfileBtn.classList.add('active');
      modeAdminBtn.classList.remove('active');
      viewProfile.classList.remove('hidden');
      viewAdmin.classList.add('hidden');
    });
  }

  if (modeAdminBtn) {
    modeAdminBtn.addEventListener('click', () => {
      modeAdminBtn.classList.add('active');
      modeProfileBtn.classList.remove('active');
      viewAdmin.classList.remove('hidden');
      viewProfile.classList.add('hidden');
    });
  }

  // Profile Subtabs
  document.querySelectorAll('.sub-tab').forEach((tabBtn) => {
    tabBtn.addEventListener('click', () => {
      document.querySelectorAll('.sub-tab').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.subtab-content').forEach(c => c.classList.add('hidden'));

      tabBtn.classList.add('active');
      const targetId = tabBtn.getAttribute('data-subtab');
      if (targetId) {
        const el = document.getElementById(targetId);
        if (el) el.classList.remove('hidden');
      }
    });
  });

  // Admin Sidebar Tabs
  document.querySelectorAll('.sidebar .nav-item').forEach((btn) => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.sidebar .nav-item').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-pane').forEach(p => p.classList.add('hidden'));

      btn.classList.add('active');
      const targetTab = btn.getAttribute('data-tab');
      const targetPane = document.getElementById(`tab-${targetTab}`);
      if (targetPane) {
        targetPane.classList.remove('hidden');
      }
    });
  });

  // Change PIN handler
  const changePinBtn = document.getElementById('change-pin-btn');
  if (changePinBtn) {
    changePinBtn.addEventListener('click', () => {
      const newPin = prompt('Indtast din nye 4-cifrede PIN-kode:');
      if (newPin && newPin.trim().length >= 4) {
        const pinCodeEl = document.getElementById('prof-pin-code');
        const kpiPinEl = document.getElementById('kpi-pin');
        if (pinCodeEl) pinCodeEl.innerText = newPin.trim();
        if (kpiPinEl) kpiPinEl.innerText = newPin.trim();
        fetch(`https://${GetParentResourceName()}/updatePin`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ pin: newPin.trim() })
        }).catch(() => null);
        alert('Din PIN-kode er blevet opdateret!');
      }
    });
  }

  // NUI Event Listener from FiveM Client
  window.addEventListener('message', (event) => {
    const item = event.data;
    if (item.type === 'setVisible') {
      if (item.visible) {
        app.classList.remove('hidden');

        if (item.isAdmin === false && modeAdminBtn) {
          modeAdminBtn.style.display = 'none';
        } else if (modeAdminBtn) {
          modeAdminBtn.style.display = 'block';
        }

        if (item.data) {
          const nodeInfo = document.getElementById('node-info');
          const kpiServerIp = document.getElementById('kpi-server-ip');
          if (nodeInfo) nodeInfo.innerText = item.data.serverIp || '127.0.0.1:30120';
          if (kpiServerIp) kpiServerIp.innerText = item.data.serverIp || '127.0.0.1:30120';
        }

        if (item.playerData) {
          currentUserData = item.playerData;
          renderProfileData(currentUserData);
        }

        fetchPlayers();
      } else {
        app.classList.add('hidden');
      }
    } else if (item.type === 'updatePlayers') {
      onlinePlayersData = item.players || [];
      renderPlayers(onlinePlayersData);
    }
  });

  // Search filter for players
  const playerSearch = document.getElementById('player-search');
  if (playerSearch) {
    playerSearch.addEventListener('input', (e) => {
      const q = e.target.value.toLowerCase();
      const filtered = onlinePlayersData.filter(p =>
        p.name.toLowerCase().includes(q) ||
        p.id.toString().includes(q) ||
        (p.steam && p.steam.toLowerCase().includes(q))
      );
      renderPlayers(filtered);
    });
  }
});

function closeTablet() {
  document.getElementById('app').classList.add('hidden');
  fetch(`https://${GetParentResourceName()}/closePanel`, { method: 'POST' });
}

function fetchPlayers() {
  fetch(`https://${GetParentResourceName()}/getPlayers`, { method: 'POST' });
}

function renderProfileData(p) {
  if (!p) return;
  const profName = document.getElementById('prof-name');
  const profCitizen = document.getElementById('prof-citizen');
  const profCash = document.getElementById('prof-cash');
  const profBank = document.getElementById('prof-bank');
  const profJob = document.getElementById('prof-job');
  const profPinCode = document.getElementById('prof-pin-code');

  if (profName) profName.innerText = p.name || 'Spiller';
  if (profCitizen) profCitizen.innerText = `CPR: ${p.citizenId || '120498-4421'}`;
  if (profCash) profCash.innerText = `kr. ${(p.cash || 0).toLocaleString('da-DK')}`;
  if (profBank) profBank.innerText = `kr. ${(p.bank || 0).toLocaleString('da-DK')}`;
  if (profJob) profJob.innerText = `${p.job || 'Civil'} · ${p.jobGrade || 'Borger'}`;
  if (profPinCode) profPinCode.innerText = p.pin || '1234';
}

function renderPlayers(players) {
  const tbody = document.getElementById('player-table-body');
  const kpiPlayers = document.getElementById('kpi-players');
  if (!tbody) return;

  tbody.innerHTML = '';
  if (kpiPlayers) kpiPlayers.innerText = `${players.length} / 128`;

  players.forEach((p) => {
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>#${p.id}</td>
      <td><strong>${p.name}</strong></td>
      <td>${p.ping || 12} ms</td>
      <td><code>${p.steam || 'N/A'}</code></td>
      <td>
        <button class="btn-primary" style="padding: 4px 8px; font-size: 0.75rem;" onclick="kickPlayer(${p.id})">Kick</button>
        <button class="btn-danger" style="padding: 4px 8px; font-size: 0.75rem;" onclick="banPlayer(${p.id})">Ban</button>
      </td>
    `;
    tbody.appendChild(tr);
  });
}

function quickReviveSelf() {
  fetch(`https://${GetParentResourceName()}/sendAction`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'REVIVE_SELF' })
  });
}

function quickNoclip() {
  fetch(`https://${GetParentResourceName()}/sendAction`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'NOCLIP' })
  });
}

function quickClearArea() {
  fetch(`https://${GetParentResourceName()}/sendAction`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ action: 'CLEAR_AREA' })
  });
}

function quickSpawnPanto() {
  fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ model: 'panto' })
  });
}

function kickPlayer(id) {
  const reason = prompt('Angiv årsag til kick:');
  if (reason) {
    fetch(`https://${GetParentResourceName()}/sendAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'KICK', targetId: id, reason })
    });
  }
}

function banPlayer(id) {
  const reason = prompt('Angiv årsag til ban:');
  if (reason) {
    fetch(`https://${GetParentResourceName()}/sendAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'BAN', targetId: id, reason })
    });
  }
}

function setWeather(weather) {
  fetch(`https://${GetParentResourceName()}/setWeather`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ weather })
  });
}

function setTime(hour, minute) {
  fetch(`https://${GetParentResourceName()}/setTime`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ hour, minute })
  });
}

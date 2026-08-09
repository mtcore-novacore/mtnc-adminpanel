// ──────────────────────────────────────────────────────
//  MTNC Admin Tablet — NUI JavaScript App
//  Modern Classic In-Game Tablet Controller
// ──────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  const app = document.getElementById('app');
  const closeBtn = document.getElementById('close-btn');
  const refreshBtn = document.getElementById('refresh-players');
  const playerList = document.getElementById('player-list');
  const playerCount = document.getElementById('player-count');
  const nodeInfo = document.getElementById('node-info');
  const licenseBadge = document.getElementById('license-badge');
  const logContainer = document.getElementById('log-container');
  const btnRunAnalyse = document.getElementById('btn-run-analyse');

  // NUI Event Listener from FiveM client
  window.addEventListener('message', (event) => {
    const item = event.data;
    if (item.type === 'setVisible') {
      if (item.visible) {
        app.classList.remove('hidden');
        if (item.data) {
          if (item.data.nodeId) nodeInfo.innerText = 'Node: ' + item.data.nodeId;
          if (item.data.tier) {
            licenseBadge.innerText = `🟢 Tier: ${item.data.tier}`;
            const anaTier = document.getElementById('ana-tier');
            if (anaTier) anaTier.innerText = item.data.tier;
          }
        }
        fetchPlayers();
      } else {
        app.classList.add('hidden');
      }
    } else if (item.type === 'updatePlayers') {
      renderPlayers(item.players || []);
    } else if (item.type === 'updateLogs') {
      renderLogs(item.logs || []);
    } else if (item.type === 'receiveAnalysis') {
      renderAnalysis(item.data);
    }
  });

  // Tab Navigation
  document.querySelectorAll('.nav-item').forEach((btn) => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-page').forEach(p => p.classList.remove('active'));

      btn.classList.add('active');
      const tabId = 'tab-' + btn.getAttribute('data-tab');
      const targetPage = document.getElementById(tabId);
      if (targetPage) targetPage.classList.add('active');
    });
  });

  // Close Panel (ESC / Button)
  closeBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closePanel`, { method: 'POST' });
  });

  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
      fetch(`https://${GetParentResourceName()}/closePanel`, { method: 'POST' });
    }
  });

  // Refresh Players
  if (refreshBtn) {
    refreshBtn.addEventListener('click', fetchPlayers);
  }

  function fetchPlayers() {
    fetch(`https://${GetParentResourceName()}/getPlayers`, { method: 'POST' });
  }

  function renderPlayers(players) {
    playerCount.innerText = players.length;
    if (!players || players.length === 0) {
      playerList.innerHTML = '<tr><td colspan="4" class="empty">Ingen spillere fundet online på serveren.</td></tr>';
      return;
    }

    playerList.innerHTML = players.map(p => `
      <tr>
        <td><strong>#${p.id}</strong></td>
        <td>${escapeHtml(p.name)}</td>
        <td><span style="color:#10b981;font-weight:600">${p.ping}ms</span></td>
        <td>
          <div style="display:flex;gap:6px;flex-wrap:wrap">
            <button onclick="sendAction('teleport', ${p.id})" style="background:rgba(59,130,246,0.15);color:#60a5fa;border:1px solid rgba(59,130,246,0.3);padding:4px 8px;border-radius:6px;font-size:0.75rem;cursor:pointer">Teleport</button>
            <button onclick="sendAction('bring', ${p.id})" style="background:rgba(139,92,246,0.15);color:#a78bfa;border:1px solid rgba(139,92,246,0.3);padding:4px 8px;border-radius:6px;font-size:0.75rem;cursor:pointer">Bring</button>
            <button onclick="sendAction('heal', ${p.id})" style="background:rgba(16,185,129,0.15);color:#34d399;border:1px solid rgba(16,185,129,0.3);padding:4px 8px;border-radius:6px;font-size:0.75rem;cursor:pointer">Heal</button>
            <button onclick="sendAction('kick', ${p.id})" style="background:rgba(245,158,11,0.15);color:#fbbf24;border:1px solid rgba(245,158,11,0.3);padding:4px 8px;border-radius:6px;font-size:0.75rem;cursor:pointer">Kick</button>
            <button onclick="sendAction('ban', ${p.id})" style="background:rgba(239,68,68,0.15);color:#fca5a5;border:1px solid rgba(239,68,68,0.3);padding:4px 8px;border-radius:6px;font-size:0.75rem;cursor:pointer">Ban</button>
          </div>
        </td>
      </tr>
    `).join('');
  }

  function renderLogs(logs) {
    if (!logs || logs.length === 0) return;
    logContainer.innerHTML = logs.map(l => `
      <div class="log-line">
        <span style="color:#64748b">[${escapeHtml(l.timestamp || '')}]</span>
        <strong style="color:#60a5fa">${escapeHtml(l.action || '')}</strong>:
        <span>${escapeHtml(l.details || '')}</span>
      </div>
    `).join('');
  }

  function renderAnalysis(data) {
    if (!data) return;
    const infoContainer = document.getElementById('analyse-server-info');
    if (infoContainer) {
      infoContainer.innerHTML = `
        <div class="info-row"><span>Licens Status</span><span class="status-pill green">${data.license?.valid ? '🟢 Aktiv & Verificeret' : '🔴 Ugyldig'}</span></div>
        <div class="info-row"><span>Licens Tier</span><strong style="color: #60a5fa;">${escapeHtml(data.license?.tier || 'ENTERPRISE')}</strong></div>
        <div class="info-row"><span>Database</span><span class="status-pill green">🟢 ${escapeHtml(data.database?.driver || 'oxmysql')} Forbundet</span></div>
        <div class="info-row"><span>DDoS Skjold</span><span class="status-pill green">🛡️ Aktivt (${escapeHtml(data.securityShield?.rateLimit || '90 req/3s')})</span></div>
        <div class="info-row"><span>Spillere Online</span><strong>${data.playersOnline || 0} / ${data.maxSlots || 64}</strong></div>
        <div class="info-row"><span>Framework Bridge</span><code>${escapeHtml(data.framework || 'standalone')}</code></div>
      `;
    }
  }

  // Run Analysis Action
  if (btnRunAnalyse) {
    btnRunAnalyse.addEventListener('click', () => {
      fetch(`https://${GetParentResourceName()}/runAnalysis`, { method: 'POST' });
    });
  }

  window.sendAction = function(action, playerId) {
    fetch(`https://${GetParentResourceName()}/playerAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action, targetId: playerId })
    });
  };

  // Spawn Vehicle
  const spawnVehBtn = document.getElementById('btn-spawn-veh');
  if (spawnVehBtn) {
    spawnVehBtn.addEventListener('click', () => {
      const model = document.getElementById('veh-model').value.trim();
      if (!model) return;
      fetch(`https://${GetParentResourceName()}/spawnVehicle`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ model })
      });
      document.getElementById('veh-model').value = '';
    });
  }

  // Delete & Repair Vehicle
  document.getElementById('btn-repair-veh')?.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/repairVehicle`, { method: 'POST' });
  });
  document.getElementById('btn-delete-veh')?.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/deleteVehicle`, { method: 'POST' });
  });

  // Staff Self Tools
  document.getElementById('btn-heal-self')?.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/staffAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action: 'heal' })
    });
  });

  document.querySelectorAll('.btn-toggle').forEach(btn => {
    btn.addEventListener('click', () => {
      const staffType = btn.getAttribute('data-staff');
      btn.classList.toggle('active');
      fetch(`https://${GetParentResourceName()}/staffAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: staffType })
      });
    });
  });

  // Weather Buttons
  document.querySelectorAll('.btn-weather').forEach(btn => {
    btn.addEventListener('click', () => {
      const weather = btn.getAttribute('data-weather');
      fetch(`https://${GetParentResourceName()}/worldAction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: 'weather', weather })
      });
    });
  });

  // Announcement
  document.getElementById('btn-send-announce')?.addEventListener('click', () => {
    const message = document.getElementById('announce-msg').value.trim();
    if (!message) return;
    fetch(`https://${GetParentResourceName()}/worldAction`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ type: 'announcement', message })
    });
    document.getElementById('announce-msg').value = '';
  });

  // Send SOS
  document.getElementById('btn-send-sos')?.addEventListener('click', () => {
    const text = document.getElementById('sos-text').value.trim();
    if (!text) return;
    fetch(`https://${GetParentResourceName()}/sendSos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: text })
    });
    document.getElementById('sos-text').value = '';
  });

  function escapeHtml(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }
});

// ── AHK bridge ──────────────────────────────────────────────
function ahk(fn, data) {
  try {
    const msg = data !== undefined ? fn + ':' + JSON.stringify(data) : fn
    window.chrome.webview.postMessage(msg)
  } catch(e) {}
}

// ── Helpers ──────────────────────────────────────────────────
const $ = id => document.getElementById(id)
function sv(id, v) { const e=$(id); if(e) e.value = v }
function sc(id, v) { const e=$(id); if(e) e.checked = !!v }
function toggleCheck(id) { const e=$(id); if(e){ e.checked=!e.checked; e.dispatchEvent(new Event('change')) } }

// ── Tab switching ────────────────────────────────────────────
function showTab(name, el) {
  document.querySelectorAll('.panel').forEach(p => p.classList.remove('active'))
  document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'))
  $('tab-' + name).classList.add('active')
  el.classList.add('active')
  ahk('RefreshDetected')
}

// ── Steppers ─────────────────────────────────────────────────
function stepInt(id, d) {
  const el = $(id)
  el.value = Math.max(parseFloat(el.min ?? -1e9), Math.min(parseFloat(el.max ?? 1e9), parseInt(el.value || 0) + d))
  save()
}
function stepFlt(id, d) {
  const el = $(id)
  el.value = (Math.round((parseFloat(el.value || 0) + d) * 10) / 10).toFixed(1)
  save()
}

// ── Build keybind grid ───────────────────────────────────────
const KEYBIND_DEFS = [
  ['keyLuckyBlock',   '🍀 Lucky Block'],
  ['keyCoinJar',      '🫙 Coin Jar'],
  ['keyComet',        '☄️ Comet'],
  ['keyPinata',       '🎉 Piñata'],
  ['keySprinkler',    '💧 Sprinkler'],
  ['keyPartyBox',     '🎁 Party Box'],
  ['keyQuestFlag',    '🚩 Quest Flag'],
  ['keyFlagLastZone', '🏁 Flag (Best Zone)'],
  ['keyPotion3',      '🧪 Tier 3 Potion'],
  ['keyPotion4',      '🧪 Tier 4 Potion'],
  ['keyPotion5',      '🧪 Tier 5 Potion'],
]

;(function buildKeybindGrid() {
  const grid = $('keybind-grid')
  KEYBIND_DEFS.forEach(([key, label]) => {
    const row = document.createElement('div')
    row.className = 'kb-row'
    row.innerHTML = `<span class="kb-label">${label}</span>
      <input class="kb-input" id="${key}" type="text" maxlength="3" value="" oninput="save()">`
    grid.appendChild(row)
  })
})()

// ── Build timing grid ────────────────────────────────────────
const TIMING_DEFS = [
  ['timePinata',        '🎉 Piñata (s)'],
  ['timeLuckyBlock',    '🍀 Lucky Block (s)'],
  ['timeCoinJar',       '🫙 Coin Jar (s)'],
  ['timeComet',         '☄️ Comet (s)'],
  ['timeMiniChests',    '📦 Mini-Chests (s)'],
  ['timeBreakables',    '🧱 Breakables (s)'],
  ['timeSuperiorChests','📦 Superior Chests (s)'],
  ['timeDiamonds',      '💎 Earn Diamonds (s)'],
  ['timeDiamondBreak',  '💎 Diamond Break (s)'],
]

;(function buildTimingGrid() {
  const grid = $('timing-grid')
  TIMING_DEFS.forEach(([key, label]) => {
    const row = document.createElement('div')
    row.className = 'timing-row'
    row.innerHTML = `<span class="timing-label">${label}</span>
      <div class="stepper">
        <button onclick="stepInt('${key}',-5)">−</button>
        <input type="number" id="${key}" value="10" min="1" max="999" oninput="save()">
        <button onclick="stepInt('${key}',5)">+</button>
      </div>`
    grid.appendChild(row)
  })
})()
window.PS99 = {
  setStatus(s) {
    const b = $('status-badge')
    b.textContent = s
    b.className = 'badge badge-' + s.toLowerCase()
  },

  setPauseBtn(t) {
    $('pauseBtn').textContent = t
  },

  setStats(t) {
    $('stats-text').textContent = t
  },

  setDetected(name, ok) {
    $('det-name').textContent = name
    $('det-dot').className = 'det-dot' + (ok ? ' ok' : '')
    const icon = $('det-icon')
    if (icon) icon.style.background = ok ? '#1d6fcc' : '#e8232a'
  },

  setActivity(loop, zone, area, quest, action, time) {
    $('act-loop').textContent   = loop   ?? '-'
    $('act-zone').textContent   = zone   ?? '-'
    $('act-area').textContent   = area   ?? '-'
    $('act-quest').textContent  = quest  ?? '-'
    $('act-action').textContent = action ?? '-'
    $('act-time').textContent   = time   ?? '-'
  },

  addLog(line) {
    const box = $('log-box')
    const el = document.createElement('div')
    el.className = 'log-line' + (line.includes('▶') || line.includes('⚠') ? ' highlight' : '')
    el.textContent = line
    box.appendChild(el)
    if (box.children.length > 60)
      box.removeChild(box.firstChild)
    box.scrollTop = box.scrollHeight
  },

  loadQuestSlots(slots) {
    const tbody = $('quest-slots')
    tbody.innerHTML = ''
    slots.forEach((slot, i) => {
      const stars = '★'.repeat(slot.stars || 1)
      const statusCls = slot.status === 'Active' ? 'qs-active' : 'qs-unknown'
      const tr = document.createElement('tr')
      if (!slot.enabled) tr.style.opacity = '0.45'
      tr.innerHTML = `
        <td style="font-size:11px;color:var(--gold)">${stars}</td>
        <td>
          <div class="qt-name">${slot.icon || '❓'} ${slot.questName || 'Unknown'}</div>
          <div class="qt-id">ID: ${slot.questId || '?'}</div>
        </td>
        <td style="color:#fff">${slot.amount ?? '-'}</td>
        <td style="color:var(--accent)">${slot.priority ?? '-'}</td>
        <td><span class="quest-status ${statusCls}">${slot.status || 'Unknown'}</span></td>
        <td style="color:var(--muted);font-size:10px">${slot.zone || '-'}</td>
        <td>
          <label class="check-row" style="justify-content:center" onclick="toggleQuestSlot(${i+1},this)">
            <input type="checkbox" ${slot.enabled ? 'checked' : ''}>
            <div class="check-box"></div>
          </label>
        </td>`
      tbody.appendChild(tr)
    })
  },

  setProfileFeedback(t, ok) {
    const e = $('profile-feedback')
    e.textContent = t
    e.style.color = ok ? 'var(--lime)' : 'var(--red)'
    setTimeout(() => e.textContent = '', 3000)
  },

  loadState(data) {
    const s = typeof data === 'string' ? JSON.parse(data) : data

    // General
    sv('numberOfLoops',    s.numberOfLoops  ?? 20)
    sv('eggsAtOnce',       s.eggsAtOnce     ?? 73)
    sv('delayModifier',    s.delayModifier  ?? 1.2)
    sc('eatFruit',         s.eatFruit       ?? true)

    // Gamepasses
    sc('hasVip',           s.hasVip            ?? false)
    sc('hasAutoFarm',      s.hasAutoFarm        ?? false)
    sc('hasDoubleStars',   s.hasDoubleStars     ?? false)
    sc('hasShinyHoverboard', s.hasShinyHoverboard ?? false)

    // Quest stars
    sc('do1Star', s.do1Star ?? true)
    sc('do2Star', s.do2Star ?? true)
    sc('do3Star', s.do3Star ?? true)
    sc('do4Star', s.do4Star ?? true)

    // Reconnect
    sc('reconnectAfterLoops', s.reconnectAfterLoops ?? true)
    sv('reconnectSeconds',    s.reconnectSeconds    ?? 45)
    sv('privateServerCode',   s.privateServerCode   ?? '')

    // Zone boosts
    sc('useFlagBestZone',      s.useFlagBestZone      ?? true)
    sc('useSprinklerBestZone', s.useSprinklerBestZone ?? true)

    // Timing
    TIMING_DEFS.forEach(([key]) => sv(key, s[key] ?? 10))

    // Keybinds
    KEYBIND_DEFS.forEach(([key]) => sv(key, s[key] ?? ''))

    // Profiles
    if (s.profiles) renderProfileList(s.profiles, s.currentProfile)
    if (s.currentProfile) document.title = 'RankBlitz Macro [' + s.currentProfile + ']'
  }
}

// ── Quest slot toggle ────────────────────────────────────────
function toggleQuestSlot(slotIndex, labelEl) {
  const cb = labelEl.querySelector('input[type=checkbox]')
  cb.checked = !cb.checked
  ahk('SetQuestEnabled', slotIndex + ':' + cb.checked)
  const row = labelEl.closest('tr')
  if (row) row.style.opacity = cb.checked ? '1' : '0.45'
}

// ── Save ─────────────────────────────────────────────────────
function save() {
  const d = {}
  const ids = [
    'numberOfLoops','eggsAtOnce','delayModifier','reconnectSeconds',
    'timePinata','timeLuckyBlock','timeCoinJar','timeComet',
    'timeMiniChests','timeBreakables','timeSuperiorChests','timeDiamonds','timeDiamondBreak'
  ]
  ids.forEach(id => { const e=$(id); if(e) d[id] = parseFloat(e.value) || 0 })

  const bools = ['eatFruit','hasVip','hasAutoFarm','hasDoubleStars','hasShinyHoverboard',
                 'do1Star','do2Star','do3Star','do4Star',
                 'reconnectAfterLoops','useFlagBestZone','useSprinklerBestZone']
  bools.forEach(id => { const e=$(id); if(e) d[id] = e.checked })

  const strings = ['privateServerCode','profileName','selectedProfile',
                   ...KEYBIND_DEFS.map(k=>k[0])]
  strings.forEach(id => { const e=$(id); if(e) d[id] = e.value })

  ahk('Save', d)
}

// ── Profiles ─────────────────────────────────────────────────
let selectedProfile = null

function renderProfileList(profiles, current) {
  const c = $('profile-list')
  c.innerHTML = ''
  profiles.forEach(name => {
    const d = document.createElement('div')
    d.className = 'profile-item' + (name === current ? ' selected' : '')
    d.textContent = name
    d.onclick = () => {
      selectedProfile = name
      sv('profileName', name)
      $('addSaveBtn').textContent = '💾 Save'
      document.querySelectorAll('.profile-item').forEach(x => x.classList.remove('selected'))
      d.classList.add('selected')
    }
    c.appendChild(d)
  })
}

function doAddProfile() {
  const name = ($('profileName').value || '').trim()
  if (!name) { window.PS99.setProfileFeedback('Enter a name first', false); return }
  ahk('AddProfile', name)
}
function doLoadProfile() {
  if (!selectedProfile) { window.PS99.setProfileFeedback('Select a profile first', false); return }
  ahk('LoadSelectedProfile', selectedProfile)
}
function doDeleteProfile() {
  if (!selectedProfile) { window.PS99.setProfileFeedback('Select a profile first', false); return }
  ahk('DeleteProfile', selectedProfile)
}

// ── Init ─────────────────────────────────────────────────────
window.addEventListener('load', () => ahk('RefreshDetected'))

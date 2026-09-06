/*
 * iOS prototypes: behavior layer.
 * Kit reference: .claude/skills/design-prototypes/references/kit.md
 *
 * Springs, not durations. Everything a finger can touch (sheets) is driven by a
 * damped spring that starts from the live on-screen value, inherits the release
 * velocity, projects momentum to choose its target, and can be grabbed mid-flight.
 * Static chrome (menus, toasts, alerts) uses short token-based CSS transitions.
 */
(function () {
  'use strict';

  const REDUCED_MOTION = matchMedia('(prefers-reduced-motion: reduce)');
  const THEME_KEY = 'ds-theme';
  const LANG_KEY = 'ds-lang';
  const DRAG_THRESHOLD = 10;       // px of hysteresis before a drag commits
  const DECELERATION = 0.998;      // Apple's scroll deceleration rate
  const SHEET_SPRING = { damping: 0.8, response: 0.3 };  // Apple: drawer / sheet
  const UI_SPRING = { damping: 1.0, response: 0.3 };     // critically damped default
  const DISMISS_RATIO = 0.4;       // projected travel past which a sheet dismisses
  const MIN_SCROLL_DELTA = 6;      // scroll hysteresis for tab bar minimize
  const HAPTIC_TICK_MS = 8;

  /* ---------------- Icons (single stroke 1.75, round caps, 24 grid) ---------------- */
  const P = (d) => `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${d}</svg>`;
  const icons = {
    overview: P('<rect x="3.5" y="3.5" width="7" height="7" rx="2"/><rect x="13.5" y="3.5" width="7" height="7" rx="2"/><rect x="3.5" y="13.5" width="7" height="7" rx="2"/><rect x="13.5" y="13.5" width="7" height="7" rx="2"/>'),
    usage: P('<path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/>'),
    apps: P('<rect x="3.5" y="3.5" width="17" height="17" rx="4"/><path d="M8 12h8M12 8v8"/>'),
    billing: P('<rect x="2.5" y="5.5" width="19" height="13" rx="3"/><path d="M2.5 10h19"/><path d="M6.5 14.5h4"/>'),
    sliders: P('<path d="M4 7h10M18 7h2M4 17h4M12 17h8"/><circle cx="16" cy="7" r="2"/><circle cx="10" cy="17" r="2"/>'),
    chevron: P('<path d="M9 6l6 6-6 6"/>'),
    back: P('<path d="M15 6l-6 6 6 6"/>'),
    down: P('<path d="M6 9l6 6 6-6"/>'),
    plus: P('<path d="M12 5v14M5 12h14"/>'),
    close: P('<path d="M6 6l12 12M18 6L6 18"/>'),
    check: P('<path d="M5 12.5l4.5 4.5L19 7"/>'),
    copy: P('<rect x="9" y="9" width="11" height="11" rx="2.5"/><path d="M5 15V6.5A2.5 2.5 0 0 1 7.5 4H15"/>'),
    warning: P('<path d="M12 3.5l9.5 16.5H2.5z"/><path d="M12 10v4.5"/><path d="M12 17.5h.01"/>'),
    info: P('<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5"/><path d="M12 8h.01"/>'),
    ellipsis: P('<circle cx="6" cy="12" r="1.2" fill="currentColor"/><circle cx="12" cy="12" r="1.2" fill="currentColor"/><circle cx="18" cy="12" r="1.2" fill="currentColor"/>'),
    key: P('<circle cx="8" cy="14" r="4.5"/><path d="M11.5 11.5L20 3"/><path d="M16.5 6.5L19 9"/>'),
    webhook: P('<path d="M10 17a4 4 0 1 1-4-4"/><path d="M14 7a4 4 0 1 1 4 4"/><path d="M6 13l4-7"/><path d="M14 7l4 6"/><path d="M6 17h12"/>'),
    link: P('<path d="M10 14a4 4 0 0 0 5.66 0l3-3a4 4 0 0 0-5.66-5.66l-1 1"/><path d="M14 10a4 4 0 0 0-5.66 0l-3 3a4 4 0 0 0 5.66 5.66l1-1"/>'),
    arrowUp: P('<path d="M12 19V5"/><path d="M6 11l6-6 6 6"/>'),
    arrowDown: P('<path d="M12 5v14"/><path d="M6 13l6 6 6-6"/>'),
    refresh: P('<path d="M20 12a8 8 0 1 1-2.34-5.66"/><path d="M20 4v5h-5"/>'),
    sun: P('<circle cx="12" cy="12" r="4"/><path d="M12 2.5v2M12 19.5v2M2.5 12h2M19.5 12h2M5.3 5.3l1.4 1.4M17.3 17.3l1.4 1.4M5.3 18.7l1.4-1.4M17.3 6.7l1.4-1.4"/>'),
    moon: P('<path d="M20 14.5A8.5 8.5 0 0 1 9.5 4a8.5 8.5 0 1 0 10.5 10.5z"/>'),
    person: P('<circle cx="12" cy="8" r="4"/><path d="M4.5 20.5a7.5 7.5 0 0 1 15 0"/>'),
    trash: P('<path d="M4 7h16"/><path d="M9.5 7V4.5h5V7"/><path d="M6.5 7l1 13h9l1-13"/>'),
    external: P('<path d="M14 4h6v6"/><path d="M20 4l-9 9"/><path d="M19 14v5a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1h5"/>'),
    wallet: P('<rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10h18"/><circle cx="16.5" cy="14.5" r="1.2" fill="currentColor"/>'),
    bolt: P('<path d="M13 3L5 14h6l-1 7 9-12h-6z"/>'),
    download: P('<path d="M12 4v11"/><path d="M7 10l5 5 5-5"/><path d="M4 20h16"/>'),
    globe: P('<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17"/><path d="M12 3.5c2.8 2.8 2.8 14.2 0 17"/><path d="M12 3.5c-2.8 2.8-2.8 14.2 0 17"/>'),
    palette: P('<path d="M12 3.5a8.5 8.5 0 1 0 0 17c1.4 0 2-.9 2-2 0-1.4-1-2 0-3 .8-.8 6.5.5 6.5-4.5A8.5 8.5 0 0 0 12 3.5z"/><circle cx="8" cy="10" r="1" fill="currentColor"/><circle cx="12" cy="7.5" r="1" fill="currentColor"/><circle cx="16" cy="10" r="1" fill="currentColor"/>'),
    shield: P('<path d="M12 3l7.5 3v6c0 4.5-3.2 7.8-7.5 9-4.3-1.2-7.5-4.5-7.5-9V6z"/>'),
    envelope: P('<rect x="3" y="5.5" width="18" height="13" rx="2.5"/><path d="M3.5 7l8.5 6 8.5-6"/>'),
    logout: P('<path d="M10 4H6a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h4"/><path d="M15 8l5 4-5 4"/><path d="M20 12H9"/>'),
    clock: P('<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>'),
    doc: P('<path d="M7 3.5h7l5 5v12H7z"/><path d="M14 3.5v5h5"/>'),
    filter: P('<path d="M4 6h16"/><path d="M7 12h10"/><path d="M10 18h4"/>'),
  };

  function injectIcons(root = document) {
    root.querySelectorAll('[data-icon]').forEach((el) => {
      const svg = icons[el.dataset.icon];
      if (!svg) { return; }
      el.innerHTML = svg;
    });
  }

  /* ---------------- Theme & language ---------------- */
  function applyTheme(pref) {
    const html = document.documentElement;
    if (pref === 'light' || pref === 'dark') { html.dataset.theme = pref; } else { delete html.dataset.theme; }
    document.querySelectorAll('[data-theme-option]').forEach((b) => {
      b.setAttribute('aria-selected', String((b.dataset.themeOption || 'system') === (pref || 'system')));
    });
  }
  function setTheme(pref) {
    try { if (pref) { localStorage.setItem(THEME_KEY, pref); } else { localStorage.removeItem(THEME_KEY); } } catch (_) { /* private mode */ }
    applyTheme(pref);
  }
  function storedTheme() { try { return localStorage.getItem(THEME_KEY); } catch (_) { return null; } }
  applyTheme(storedTheme());

  function storedLang() { try { return localStorage.getItem(LANG_KEY) || 'en'; } catch (_) { return 'en'; } }
  function setLang(lang) { try { localStorage.setItem(LANG_KEY, lang); } catch (_) { /* ignore */ } applyLang(lang); }
  function applyLang(lang) {
    document.documentElement.lang = lang;
    document.querySelectorAll('[data-en]').forEach((el) => {
      const text = lang === 'fr' ? el.dataset.fr : el.dataset.en;
      if (text !== undefined) { el.textContent = text; }
    });
    document.querySelectorAll('[data-lang-option]').forEach((b) => b.setAttribute('aria-selected', String(b.dataset.langOption === lang)));
  }

  /* ---------------- Physics ---------------- */
  // Apple's projection: where a flick would come to rest on its own.
  function project(velocity, rate = DECELERATION) { return (velocity / 1000) * rate / (1 - rate); }
  // Progressive resistance past a boundary.
  function rubberband(overshoot, dimension, constant = 0.55) {
    return (overshoot * dimension * constant) / (dimension + constant * Math.abs(overshoot));
  }

  /**
   * Damped spring on a single value. damping = ratio (1 = no overshoot),
   * response = seconds to approach the target. Retargeting keeps velocity.
   */
  class Spring {
    constructor(onFrame, { damping, response } = UI_SPRING) {
      this.onFrame = onFrame; this.damping = damping; this.response = response;
      this.value = 0; this.velocity = 0; this.target = 0; this.raf = 0; this.last = 0; this.onRest = null;
    }
    set(value) { this.value = value; this.velocity = 0; this.stop(); this.onFrame(value); }
    to(target, { velocity, onRest } = {}) {
      this.target = target; this.onRest = onRest || null;
      if (typeof velocity === 'number') { this.velocity = velocity; }
      if (REDUCED_MOTION.matches) { this.value = target; this.velocity = 0; this.onFrame(target); this.finish(); return; }
      if (!this.raf) { this.last = performance.now(); this.raf = requestAnimationFrame((t) => this.tick(t)); }
    }
    stop() { if (this.raf) { cancelAnimationFrame(this.raf); this.raf = 0; } }
    finish() { this.stop(); const cb = this.onRest; this.onRest = null; if (cb) { cb(); } }
    tick(now) {
      const dt = Math.min(0.032, (now - this.last) / 1000); this.last = now;
      const omega = (2 * Math.PI) / this.response;
      const k = omega * omega, c = 2 * this.damping * omega;
      // semi-implicit Euler, stable at 60/120 Hz
      const x = this.value - this.target;
      this.velocity += (-k * x - c * this.velocity) * dt;
      this.value += this.velocity * dt;
      this.onFrame(this.value);
      const settled = Math.abs(this.value - this.target) < 0.1 && Math.abs(this.velocity) < 5;
      if (settled) { this.value = this.target; this.velocity = 0; this.onFrame(this.value); this.raf = 0; this.finish(); return; }
      this.raf = requestAnimationFrame((t) => this.tick(t));
    }
  }

  /* ---------------- Haptics (Vibration API where it exists) ---------------- */
  function haptic(pattern = HAPTIC_TICK_MS) { if (navigator.vibrate) { navigator.vibrate(pattern); } }

  /* ---------------- Device wiring: scroll edge + tab bar minimize ---------------- */
  function wireDevice(device) {
    const screen = device.querySelector('.screen');
    if (!screen) { return; }
    let lastTop = screen.scrollTop;
    const update = () => {
      const top = screen.scrollTop;
      device.dataset.scrolled = String(top > 8);
      const atBottom = top + screen.clientHeight >= screen.scrollHeight - 4;
      device.dataset.scrolledBottom = String(!atBottom);
      const delta = top - lastTop;
      if (Math.abs(delta) > MIN_SCROLL_DELTA) {
        // iOS 26: the tab bar minimizes while scrolling down, comes back on scroll up or at the top
        device.dataset.minimized = String(delta > 0 && top > 64);
        lastTop = top;
      }
      if (top <= 0) { device.dataset.minimized = 'false'; }
    };
    screen.addEventListener('scroll', update, { passive: true });
    update();
    // Tapping the minimized bar restores it
    const bar = device.querySelector('.tabbar');
    if (bar) { bar.addEventListener('click', (e) => { if (device.dataset.minimized === 'true') { e.preventDefault(); device.dataset.minimized = 'false'; } }); }
  }

  /* ---------------- Sheet: draggable, spring-driven, interruptible ---------------- */
  const sheets = new Map();

  function sheetController(el) {
    const device = el.closest('.device');
    const scrim = device.querySelector('.scrim');
    let height = 0, open = false;
    const spring = new Spring((y) => { el.style.transform = `translateY(${y}px)`; if (scrim) { scrim.style.opacity = String(Math.max(0, 1 - y / Math.max(1, height))); } }, SHEET_SPRING);

    function measure() { height = el.offsetHeight + 24; }
    function show() {
      measure();
      open = true;
      el.dataset.open = 'true'; if (scrim) { scrim.dataset.open = 'true'; }
      device.dataset.sheetOpen = 'true';
      spring.set(height);            // start from off-screen (or the live value if interrupted)
      spring.to(0);
      el.querySelector('[data-autofocus]')?.focus({ preventScroll: true });
      device.dispatchEvent(new CustomEvent('ds:sheet-open', { detail: { id: el.dataset.sheet } }));
    }
    function hide(velocity) {
      open = false;
      device.dataset.sheetOpen = 'false';
      if (scrim) { scrim.dataset.open = 'false'; scrim.style.opacity = ''; }
      spring.to(height, { velocity, onRest: () => { el.dataset.open = 'false'; el.style.transform = ''; } });
      device.dispatchEvent(new CustomEvent('ds:sheet-close', { detail: { id: el.dataset.sheet } }));
    }
    function toggleTo(target) { if (target) { show(); } else { hide(); } }

    // Drag: 1:1 with the finger, rubber-band above the resting point, project on release.
    let dragging = false, committed = false, startY = 0, startValue = 0, history = [];
    el.addEventListener('pointerdown', (e) => {
      const body = el.querySelector('.sheet__body');
      const inBody = body && body.contains(e.target);
      if (inBody && body.scrollTop > 0) { return; }          // let the content scroll first
      if (e.target.closest('button, a, input, textarea, select, [role="switch"]')) { committed = false; dragging = false; history = [{ y: e.clientY, t: e.timeStamp }]; startY = e.clientY; startValue = spring.value; el.dataset.pendingDrag = 'true'; return; }
      begin(e);
    });
    function begin(e) {
      dragging = true; committed = false; startY = e.clientY; startValue = spring.value; history = [{ y: e.clientY, t: e.timeStamp }];
      spring.stop();                                          // grab it mid-flight: the value stays where it is on screen
      el.setPointerCapture(e.pointerId);
    }
    el.addEventListener('pointermove', (e) => {
      if (!dragging && el.dataset.pendingDrag === 'true') {
        if (Math.abs(e.clientY - startY) > DRAG_THRESHOLD) { delete el.dataset.pendingDrag; begin(e); } else { return; }
      }
      if (!dragging) { return; }
      const dy = e.clientY - startY;
      if (!committed && Math.abs(dy) < DRAG_THRESHOLD) { return; }
      committed = true;
      history.push({ y: e.clientY, t: e.timeStamp }); if (history.length > 6) { history.shift(); }
      let y = startValue + dy;
      if (y < 0) { y = rubberband(y, height); }               // above rest: resist, never hard-stop
      spring.value = y; spring.onFrame(y);
    });
    const release = (e) => {
      delete el.dataset.pendingDrag;
      if (!dragging) { return; }
      dragging = false;
      if (!committed) { return; }
      const a = history[0], b = history[history.length - 1];
      const dt = Math.max(1, b.t - a.t);
      const velocity = ((b.y - a.y) / dt) * 1000;               // px/s
      const projected = spring.value + project(velocity);
      const dismiss = projected > height * DISMISS_RATIO;
      if (dismiss) { hide(velocity); } else { open = true; spring.to(0, { velocity }); }
      if (e.pointerId !== undefined) { try { el.releasePointerCapture(e.pointerId); } catch (_) { /* already released */ } }
    };
    el.addEventListener('pointerup', release);
    el.addEventListener('pointercancel', release);

    return { show, hide, toggleTo, get open() { return open; } };
  }

  function openSheet(id) { const s = sheets.get(id); if (s) { s.show(); } }
  function closeSheet(id) {
    if (id) { const s = sheets.get(id); if (s) { s.hide(); } return; }
    sheets.forEach((s) => { if (s.open) { s.hide(); } });
  }

  /* ---------------- Alert, menu, toast ---------------- */
  function openAlert(id) {
    const el = document.querySelector(`.alert[data-alert="${id}"]`);
    if (!el) { return; }
    const device = el.closest('.device'); const scrim = device.querySelector('.scrim');
    el.dataset.open = 'true'; if (scrim) { scrim.dataset.open = 'true'; scrim.style.opacity = ''; }
    device.dataset.alertOpen = 'true';
  }
  function closeAlert() {
    document.querySelectorAll('.alert[data-open="true"]').forEach((el) => {
      el.dataset.open = 'false';
      const device = el.closest('.device'); const scrim = device.querySelector('.scrim');
      delete device.dataset.alertOpen;
      if (scrim && device.dataset.sheetOpen !== 'true') { scrim.dataset.open = 'false'; }
    });
  }
  function toggleMenu(id, anchor) {
    const el = document.querySelector(`.menu[data-menu="${id}"]`);
    if (!el) { return; }
    const isOpen = el.dataset.open === 'true';
    closeMenus();
    if (isOpen) { return; }
    const device = el.closest('.device'); const dr = device.getBoundingClientRect(); const ar = anchor.getBoundingClientRect();
    // Anchored to the trigger: it grows out of the button, top-right corner pinned.
    el.style.top = `${ar.bottom - dr.top + 6}px`;
    el.style.right = `${dr.right - ar.right}px`;
    el.dataset.open = 'true';
  }
  function closeMenus() { document.querySelectorAll('.menu[data-open="true"]').forEach((m) => { m.dataset.open = 'false'; }); }

  let toastTimer = 0;
  function toast(text, device) {
    const host = device || document.querySelector('.device');
    let el = host.querySelector('.toast');
    if (!el) { el = document.createElement('div'); el.className = 'toast glass'; el.setAttribute('role', 'status'); host.appendChild(el); }
    el.innerHTML = `${icons.check}<span></span>`; el.lastChild.textContent = text;
    el.dataset.open = 'true'; clearTimeout(toastTimer); toastTimer = setTimeout(() => { el.dataset.open = 'false'; }, 1800);
  }
  async function copy(text, device) {
    try { await navigator.clipboard.writeText(text); } catch (_) { /* prototype: clipboard may be unavailable */ }
    haptic(); toast('Copied to clipboard', device);
  }

  /* ---------------- Segmented control: sliding thumb on a spring ---------------- */
  function wireSegmented(seg) {
    const buttons = [...seg.querySelectorAll('button')];
    let thumb = seg.querySelector('.segmented__thumb');
    if (!thumb) { thumb = document.createElement('span'); thumb.className = 'segmented__thumb'; seg.prepend(thumb); }
    const x = new Spring((v) => { thumb.style.transform = `translateX(${v}px)`; }, UI_SPRING);
    const w = new Spring((v) => { thumb.style.width = `${v}px`; }, UI_SPRING);
    function select(btn, animate = true) {
      buttons.forEach((b) => b.setAttribute('aria-selected', String(b === btn)));
      const left = btn.offsetLeft - 3, width = btn.offsetWidth;
      if (animate) { x.to(left); w.to(width); } else { x.set(left); w.set(width); }
      const panelId = btn.dataset.panel;
      if (panelId) {
        const scope = seg.closest('.device') || document;
        scope.querySelectorAll(`[data-panel-group="${seg.dataset.group || 'default'}"]`).forEach((p) => { p.hidden = p.dataset.panelId !== panelId; });
      }
      seg.dispatchEvent(new CustomEvent('ds:segment', { detail: { value: btn.dataset.value || btn.dataset.panel }, bubbles: true }));
    }
    buttons.forEach((b) => b.addEventListener('pointerdown', () => { haptic(); select(b); }));
    const initial = buttons.find((b) => b.getAttribute('aria-selected') === 'true') || buttons[0];
    requestAnimationFrame(() => select(initial, false));
  }

  /* ---------------- Formatting ---------------- */
  function money(amount, currency = 'EUR', locale = storedLang() === 'fr' ? 'fr-FR' : 'en-IE') {
    return new Intl.NumberFormat(locale, { style: 'currency', currency, minimumFractionDigits: 2 }).format(amount);
  }
  function compact(n) { return new Intl.NumberFormat('en', { notation: 'compact', maximumFractionDigits: 1 }).format(n); }
  function param(name, fallback = null) { return new URLSearchParams(location.search).get(name) ?? fallback; }

  /* ---------------- Declarative wiring ---------------- */
  document.addEventListener('DOMContentLoaded', () => {
    injectIcons();
    applyLang(storedLang());
    document.querySelectorAll('.device').forEach(wireDevice);
    document.querySelectorAll('.sheet').forEach((el) => sheets.set(el.dataset.sheet, sheetController(el)));
    document.querySelectorAll('.segmented').forEach(wireSegmented);

    // Any bar chart: stagger the bars in, once.
    document.querySelectorAll('.bars').forEach((bars) => {
      const spans = bars.querySelectorAll('span');
      spans.forEach((s, i) => { s.style.transform = 'scaleY(0)'; s.style.transitionDelay = `${Math.min(i * 12, 240)}ms`; });
      requestAnimationFrame(() => requestAnimationFrame(() => spans.forEach((s) => { s.style.transform = 'scaleY(1)'; })));
    });

    document.addEventListener('pointerdown', (e) => {
      // Respond on pointer-down: haptic tick on primary controls.
      if (e.target.closest('.btn, .tab, .chip, .toggle')) { haptic(); }
      if (!e.target.closest('.menu, [data-toggle-menu]')) { closeMenus(); }
    });

    document.addEventListener('click', (e) => {
      const t = e.target.closest('[data-open-sheet], [data-close-sheet], [data-open-alert], [data-close-alert], [data-toggle-menu], [data-copy], [data-toast], [data-toggle], [data-press], [data-theme-option], [data-lang-option], .scrim, [data-go]');
      if (!t) { return; }
      const device = t.closest('.device');
      if (t.matches('.scrim')) { closeSheet(); closeAlert(); return; }
      if (t.dataset.openSheet !== undefined) { e.preventDefault(); closeMenus(); closeAlert(); openSheet(t.dataset.openSheet); }
      if (t.dataset.closeSheet !== undefined) { e.preventDefault(); closeSheet(t.dataset.closeSheet || undefined); }
      if (t.dataset.openAlert !== undefined) { e.preventDefault(); closeMenus(); openAlert(t.dataset.openAlert); }
      if (t.dataset.closeAlert !== undefined) { e.preventDefault(); closeAlert(); }
      if (t.dataset.toggleMenu !== undefined) { e.preventDefault(); toggleMenu(t.dataset.toggleMenu, t); }
      if (t.dataset.copy !== undefined) { e.preventDefault(); copy(t.dataset.copy, device); }
      if (t.dataset.toast !== undefined) { e.preventDefault(); haptic(); toast(t.dataset.toast, device); }
      if (t.dataset.toggle !== undefined) { const on = t.getAttribute('aria-checked') === 'true'; t.setAttribute('aria-checked', String(!on)); haptic(); }
      if (t.dataset.press !== undefined) {
        const group = t.dataset.press; const on = t.getAttribute('aria-pressed') === 'true';
        if (group) { document.querySelectorAll(`[data-press="${group}"]`).forEach((c) => c.setAttribute('aria-pressed', 'false')); t.setAttribute('aria-pressed', 'true'); }
        else { t.setAttribute('aria-pressed', String(!on)); }
      }
      if (t.dataset.themeOption !== undefined) { setTheme(t.dataset.themeOption || null); }
      if (t.dataset.langOption !== undefined) { setLang(t.dataset.langOption); }
      if (t.dataset.go !== undefined) { e.preventDefault(); setTimeout(() => { location.href = t.dataset.go; }, 90); }
    });

    // Escape closes the topmost layer
    document.addEventListener('keydown', (e) => { if (e.key === 'Escape') { closeMenus(); closeAlert(); closeSheet(); } });

    // Deep-link a sheet: ?sheet=id
    const s = param('sheet'); if (s) { setTimeout(() => openSheet(s), 250); }
  });

  window.DS = { icons, injectIcons, Spring, project, rubberband, openSheet, closeSheet, openAlert, closeAlert, toggleMenu, toast, copy, haptic, money, compact, param, setTheme, storedTheme, setLang, storedLang, wireSegmented };
})();

// ============================================
// common.js - BrainrotMarket
// Funciones compartidas entre todas las páginas
// ============================================

// Configuración de Supabase
const SUPA_URL = 'https://qpulidzwqmgvrmhfawxb.supabase.co';
const SUPA_KEY = 'sb_publishable_3v7n7Uxb8aYIQTFj9psHqQ_f8XXdaEh';
const { createClient } = supabase;
const db = createClient(SUPA_URL, SUPA_KEY);

// ===== TOAST NOTIFICATIONS =====
function showToast(msg, type = 'ok') {
  let t = document.getElementById('toast');
  if (!t) {
    t = document.createElement('div');
    t.id = 'toast';
    t.className = 'toast';
    document.body.appendChild(t);
  }
  t.textContent = msg;
  t.className = 'toast ' + type;
  t.classList.add('show');
  setTimeout(() => t.classList.remove('show'), 3500);
}

// ===== TIME AGO =====
function timeAgo(ts) {
  if (!ts) return 'recientemente';
  const d = (Date.now() - new Date(ts).getTime()) / 60000;
  if (d < 1) return 'ahora mismo';
  if (d < 60) return 'hace ' + Math.floor(d) + ' min';
  if (d < 1440) return 'hace ' + Math.floor(d / 60) + 'h';
  return 'hace ' + Math.floor(d / 1440) + 'd';
}

// ===== ESCAPAR HTML (seguridad) =====
function escHtml(str) {
  if (!str) return '';
  return str.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;');
}

// ===== VALIDAR YAPE =====
function isValidYape(num) {
  return /^9\d{8}$/.test(num);
}

// ===== VALIDAR EMAIL =====
function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// ===== NAVEGACIÓN SIDEBAR =====
function toggleSidebar() {
  document.querySelectorAll('.sidebar').forEach(s => s.classList.toggle('open'));
  document.querySelectorAll('.sov').forEach(o => o.classList.toggle('show'));
}

function closeSidebar() {
  document.querySelectorAll('.sidebar').forEach(s => s.classList.remove('open'));
  document.querySelectorAll('.sov').forEach(o => o.classList.remove('show'));
}

// ===== RAREZAS =====
function getRarezaLabel(rareza) {
  const map = { L: 'Legendary', E: 'Epic', R: 'Rare', C: 'Common' };
  return map[rareza] || rareza;
}

function getRarezaClass(rareza) {
  return `rar-${rareza}`;
}

// ===== HASH CONTRASEÑA =====
async function hashPassword(pass) {
  const enc = new TextEncoder().encode(pass);
  const buf = await crypto.subtle.digest('SHA-256', enc);
  return Array.from(new Uint8Array(buf)).map(b => b.toString(16).padStart(2, '0')).join('');
}
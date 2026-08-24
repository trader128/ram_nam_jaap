#!/usr/bin/env node
/**
 * Pulls Navamsha panchang for Ujjain and writes Firestore `panchang/{yyyy-MM-dd}`.
 *
 * The Flutter app never sees NAVAMSHA_API_KEY. This script is the only caller.
 *
 *   export NAVAMSHA_API_KEY='…'
 *   node tool/navamsha/sync.mjs --probe          # one day, print JSON, no write
 *   node tool/navamsha/sync.mjs --dry-run        # 45 days, print summaries
 *   node tool/navamsha/sync.mjs                  # write to Firestore
 *
 * Firestore writes need Application Default Credentials:
 *   gcloud auth application-default login
 */
import { existsSync, readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const BASE = 'https://api.navamsha.in';
const PROJECT = process.env.FIREBASE_PROJECT_ID || 'bhakti-sawarun';
const PLACE = {
  label: 'उज्जैन',
  latitude: 23.1765,
  longitude: 75.7885,
  timezone: 5.5,
  hours: 6,
  minutes: 0,
};

loadDotEnv();

const args = new Set(process.argv.slice(2));
const probe = args.has('--probe');
const dryRun = args.has('--dry-run') || probe;
const days = numberFlag('--days') ?? (probe ? 1 : 45);
const apiKey = sanitizeKey(process.env.NAVAMSHA_API_KEY);

if (!apiKey) {
  console.error(
    'NAVAMSHA_API_KEY is missing. Export the key from your Navamsha dashboard,',
    'not the Firebase JSON.',
  );
  process.exit(1);
}

if (apiKey.startsWith('AIza') || apiKey.includes('firebase-adminsdk')) {
  console.error(
    'That value looks like a Firebase key. Navamsha keys come from',
    'https://www.navamsha.in/ after you sign in, under API keys.',
  );
  process.exit(1);
}

if (/paste[-_ ]the|your-key|your_key|navamsha-key-here/i.test(apiKey)) {
  console.error(
    'NAVAMSHA_API_KEY is still the example text from the instructions.',
    'Export the real 61-character key copied from the Navamsha dashboard.',
  );
  process.exit(1);
}

console.log(
  `Using Navamsha key: length=${apiKey.length} ${keyHint(apiKey)}`,
);

let authHeaders = { 'X-API-Key': apiKey };

const health = await navamsha('GET', '/api/v1/health');
if (health.statusCode >= 400) {
  console.error('Navamsha health check failed:', health.statusCode, health.body);
  process.exit(1);
}

const start = new Date();
start.setHours(0, 0, 0, 0);
const written = [];

for (let offset = 0; offset < days; offset += 1) {
  const date = new Date(start);
  date.setDate(start.getDate() + offset);
  const key = isoDate(date);
  const payload = {
    year: date.getFullYear(),
    month: date.getMonth() + 1,
    date: date.getDate(),
    hours: PLACE.hours,
    minutes: PLACE.minutes,
    latitude: PLACE.latitude,
    longitude: PLACE.longitude,
    timezone: PLACE.timezone,
    settings: {
      ayanamsha: 'lahiri',
      language: 'hi',
      observation_point: 'topocentric',
    },
  };

  let result = await navamsha('POST', '/api/v1/astrology/panchang', payload);
  if (result.statusCode === 401 && offset === 0) {
    result = await resolveAuth(payload);
  }
  if (result.statusCode >= 400 && result.statusCode !== 401) {
    result = await navamsha('POST', '/api/v1/panchang/full', payload);
  }
  if (result.statusCode >= 400) {
    console.error(`${key} failed:`, result.statusCode, brief(result.body));
    if (result.statusCode === 401) {
      console.error(
        '\nNavamsha did not accept this key. Copy the API key from',
        'https://www.navamsha.in/ (dashboard → API keys), not Firebase.',
        'Re-export with no spaces or extra quotes, then run --probe again.',
      );
    }
    process.exit(1);
  }

  const document = {
    date: key,
    placeLabel: PLACE.label,
    latitude: PLACE.latitude,
    longitude: PLACE.longitude,
    timezone: PLACE.timezone,
    source: 'navamsha',
    fetchedAt: new Date().toISOString(),
    output: result.body?.output ?? result.body,
  };
  written.push(document);

  if (probe) {
    console.log(JSON.stringify(document, null, 2));
  } else {
    const tithi = limbName(document.output?.tithi) ?? '?';
    console.log(`${key}  tithi=${tithi}`);
  }

  if (offset + 1 < days) {
    await sleep(150);
  }
}

if (dryRun) {
  console.log(
    `\nDry run: ${written.length} day(s) fetched, Firestore untouched.`,
  );
  process.exit(0);
}

const { initializeApp, applicationDefault, cert } = await import(
  'firebase-admin/app'
);
const { getFirestore } = await import('firebase-admin/firestore');

initializeApp({
  credential: firebaseCredential(cert, applicationDefault),
  projectId: PROJECT,
});
const db = getFirestore();

for (const document of written) {
  await db.collection('panchang').doc(document.date).set(document);
}

console.log(
  `\nWrote ${written.length} panchang document(s) to ${PROJECT}.`,
);

function numberFlag(name) {
  const index = process.argv.indexOf(name);
  if (index === -1 || index === process.argv.length - 1) {
    return null;
  }
  const value = Number.parseInt(process.argv[index + 1], 10);
  return Number.isFinite(value) ? value : null;
}

function sanitizeKey(value) {
  if (!value) {
    return '';
  }
  let key = value.trim().replace(/^['"]|['"]$/g, '').trim();
  if (key.toLowerCase().startsWith('bearer ')) {
    key = key.slice(7).trim();
  }
  return key;
}

function keyHint(key) {
  if (key.startsWith('AIza')) {
    return '(looks like a Google/Firebase web key — wrong source)';
  }
  if (/^[0-9a-f-]{36}$/i.test(key)) {
    return '(uuid-shaped)';
  }
  if (key.length < 16) {
    return '(short — copy may be truncated)';
  }
  if (/\s/.test(key)) {
    return '(contains whitespace — copy again)';
  }
  return '(shape looks ok)';
}

function authAttempts(key) {
  return [
    { label: 'X-API-Key', headers: { 'X-API-Key': key } },
    { label: 'x-api-key', headers: { 'x-api-key': key } },
    { label: 'Authorization Bearer', headers: { Authorization: `Bearer ${key}` } },
  ];
}

async function navamsha(method, path, body) {
  const response = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      ...authHeaders,
      Accept: 'application/json',
      ...(body ? { 'Content-Type': 'application/json' } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let parsed = null;
  const text = await response.text();
  try {
    parsed = text ? JSON.parse(text) : null;
  } catch {
    parsed = { raw: text };
  }
  return { statusCode: response.status, body: parsed };
}

function isoDate(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function limbName(value) {
  const limb = Array.isArray(value) ? value[0] : value;
  if (typeof limb === 'string') {
    return limb;
  }
  if (limb && typeof limb === 'object') {
    return limb.name_hi || limb.nameHi || limb.name || limb.name_en;
  }
  return null;
}

function brief(value) {
  const text = typeof value === 'string' ? value : JSON.stringify(value);
  return text.length > 240 ? `${text.slice(0, 240)}…` : text;
}

function sleep(ms) {
  return new Promise((resolveSleep) => {
    setTimeout(resolveSleep, ms);
  });
}

async function resolveAuth(payload) {
  for (const attempt of authAttempts(apiKey)) {
    authHeaders = attempt.headers;
    const result = await navamsha(
      'POST',
      '/api/v1/astrology/panchang',
      payload,
    );
    if (result.statusCode !== 401) {
      console.log(`Auth accepted via ${attempt.label}`);
      return result;
    }
  }
  authHeaders = { 'X-API-Key': apiKey };
  return { statusCode: 401, body: { detail: 'Invalid or missing API key' } };
}

function firebaseCredential(cert, applicationDefault) {
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT;
  if (raw && raw.trim()) {
    const trimmed = raw.trim();
    let parsed;
    try {
      parsed = JSON.parse(trimmed);
    } catch {
      parsed = JSON.parse(Buffer.from(trimmed, 'base64').toString('utf8'));
    }
    return cert(parsed);
  }
  return applicationDefault();
}

function loadDotEnv() {
  for (const relative of ['.env', 'tool/navamsha/.env']) {
    const path = resolve(ROOT, relative);
    if (!existsSync(path)) {
      continue;
    }
    for (const line of readFileSync(path, 'utf8').split('\n')) {
      const trimmed = line.trim();
      if (!trimmed || trimmed.startsWith('#')) {
        continue;
      }
      const match = trimmed.match(/^([A-Za-z_][A-Za-z0-9_]*)=(.*)$/);
      if (!match || process.env[match[1]]) {
        continue;
      }
      process.env[match[1]] = match[2].replace(/^['"]|['"]$/g, '');
    }
  }
}

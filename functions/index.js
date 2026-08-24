'use strict';

/**
 * Prokerala proxy. Navamsha stays on the weekly panchang job.
 *
 *   drawHoroscope — GET /v2/astrology/kundli
 *   askHoroscope  — chart Q&A routed to kundli / dosha / dasha / daily
 *
 * Secrets: PROKERALA_CLIENT_ID, PROKERALA_CLIENT_SECRET
 */
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const { readFileSync, existsSync } = require('node:fs');
const { resolve } = require('node:path');

loadDotEnv();
initializeApp();

const db = getFirestore();
const BASE = 'https://api.prokerala.com';
const REGION = 'asia-south1';
const clientIdSecret = defineSecret('PROKERALA_CLIENT_ID');
const clientSecretSecret = defineSecret('PROKERALA_CLIENT_SECRET');

const DRAW_LIMIT = 8;
const ASK_LIMIT = 20;
const CALL_OPTIONS = {
  region: REGION,
  cors: true,
  secrets: [clientIdSecret, clientSecretSecret],
};

let tokenCache = { value: '', expiresAt: 0 };

exports.drawHoroscope = onCall(CALL_OPTIONS, async (request) => {
  const uid = requireAuth(request);
  const birth = parseBirth(request.data);
  await bumpUsage(uid, 'draws', DRAW_LIMIT);
  const language = birth.language;
  const kundli = await prokeralaGet('/v2/astrology/kundli', {
    ayanamsa: 1,
    coordinates: birth.coordinates,
    datetime: birth.datetime,
    la: language,
  });
  const reading = sanitizeKundli(kundli, birth);
  await saveReading(uid, birth, reading);
  return { reading, chatPriceInr: 299 };
});

exports.askHoroscope = onCall(CALL_OPTIONS, async (request) => {
  const uid = requireAuth(request);
  const birth = parseBirth(request.data);
  const message = String(request.data?.message ?? '').trim();
  if (message.length < 2 || message.length > 500) {
    throw new HttpsError('invalid-argument', 'Ask a short question about the chart.');
  }
  await bumpUsage(uid, 'asks', ASK_LIMIT);
  const language = birth.language;
  const topic = routeTopic(message);
  const answer = await answerTopic({ birth, language, topic, message });
  const turn = {
    topic,
    question: message,
    answer: answer.text,
    title: answer.title,
    at: new Date().toISOString(),
  };
  await db
    .collection('users')
    .doc(uid)
    .collection('astrology')
    .doc('thread')
    .collection('messages')
    .add({
      ...turn,
      role: 'assistant',
      source: 'prokerala',
      createdAt: FieldValue.serverTimestamp(),
    });
  return { turn, chatPriceInr: 299 };
});

function requireAuth(request) {
  if (!request.auth?.uid) {
    throw new HttpsError(
      'unauthenticated',
      'Sign-in is required for kundali. It is anonymous and stays on this device.',
    );
  }
  return request.auth.uid;
}

function parseBirth(data) {
  const year = asInt(data?.year);
  const month = asInt(data?.month);
  const date = asInt(data?.date);
  const hours = asInt(data?.hours);
  const minutes = asInt(data?.minutes);
  const latitude = Number(data?.latitude);
  const longitude = Number(data?.longitude);
  const timezone = Number(data?.timezone ?? 5.5);
  const placeLabel = String(data?.placeLabel ?? '').trim().slice(0, 80);
  if (
    !Number.isFinite(year) ||
    !Number.isFinite(month) ||
    !Number.isFinite(date) ||
    !Number.isFinite(hours) ||
    !Number.isFinite(minutes) ||
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude)
  ) {
    throw new HttpsError('invalid-argument', 'Birth date, time, and place are required.');
  }
  if (year < 1900 || year > 2100 || month < 1 || month > 12 || date < 1 || date > 31) {
    throw new HttpsError('invalid-argument', 'That birth date is out of range.');
  }
  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
    throw new HttpsError('invalid-argument', 'That birth time is out of range.');
  }
  if (Math.abs(latitude) > 90 || Math.abs(longitude) > 180) {
    throw new HttpsError('invalid-argument', 'That place is out of range.');
  }
  const language = data?.language === 'hi' || data?.language === 'hindi' ? 'hi' : 'en';
  return {
    year,
    month,
    date,
    hours,
    minutes,
    latitude,
    longitude,
    timezone,
    placeLabel: placeLabel || 'India',
    language,
    coordinates: `${latitude},${longitude}`,
    datetime: isoDatetime({ year, month, date, hours, minutes, timezone }),
  };
}

function isoDatetime({ year, month, date, hours, minutes, timezone }) {
  const pad = (n, w = 2) => String(n).padStart(w, '0');
  const offsetMinutes = Math.round(Number(timezone) * 60);
  const sign = offsetMinutes >= 0 ? '+' : '-';
  const abs = Math.abs(offsetMinutes);
  const oh = pad(Math.floor(abs / 60));
  const om = pad(abs % 60);
  return `${year}-${pad(month)}-${pad(date)}T${pad(hours)}:${pad(minutes)}:00${sign}${oh}:${om}`;
}

function routeTopic(message) {
  const t = message.toLowerCase();
  if (/mangal|manglik|kuja|मंगल|मांगलिक|कुज/.test(t)) {
    return 'mangal-dosha';
  }
  if (/kaal|kal.?sarp|कालसर्प|काल सर्प/.test(t)) {
    return 'kaal-sarp-dosha';
  }
  if (/sade.?sati|साढ़े|साढे/.test(t)) {
    return 'sade-sati';
  }
  if (/dasha|mahadasha|antardasha|दशा|महादशा/.test(t)) {
    return 'dasha-periods';
  }
  if (
    /today|daily|prediction|आज|दैनिक|rashifal|राशिफल|horoscope/.test(t)
  ) {
    return 'daily';
  }
  return 'kundli';
}

async function answerTopic({ birth, language, topic }) {
  const chartParams = {
    ayanamsa: 1,
    coordinates: birth.coordinates,
    datetime: birth.datetime,
    la: language,
  };

  if (topic === 'mangal-dosha') {
    const data = await prokeralaGet('/v2/astrology/mangal-dosha', chartParams);
    return {
      title: language === 'hi' ? 'मंगल दोष' : 'Mangal dosha',
      text: pickText(data) || (language === 'hi' ? 'विवरण नहीं मिला।' : 'No details returned.'),
    };
  }
  if (topic === 'kaal-sarp-dosha') {
    const data = await prokeralaGet('/v2/astrology/kaal-sarp-dosha', chartParams);
    return {
      title: language === 'hi' ? 'कालसर्प दोष' : 'Kaal sarp dosha',
      text: pickText(data) || (language === 'hi' ? 'विवरण नहीं मिला।' : 'No details returned.'),
    };
  }
  if (topic === 'sade-sati') {
    const data = await prokeralaGet('/v2/astrology/sade-sati', chartParams);
    return {
      title: language === 'hi' ? 'साढ़े साती' : 'Sade sati',
      text: pickText(data) || (language === 'hi' ? 'विवरण नहीं मिला।' : 'No details returned.'),
    };
  }
  if (topic === 'dasha-periods') {
    const data = await prokeralaGet('/v2/astrology/dasha-periods', chartParams);
    return {
      title: language === 'hi' ? 'वर्तमान दशा' : 'Current dasha',
      text: formatCurrentDasha(data, language),
    };
  }
  if (topic === 'daily') {
    const kundli = await prokeralaGet('/v2/astrology/kundli', chartParams);
    const sign = tropicalSign(kundli);
    if (!sign) {
      return {
        title: language === 'hi' ? 'आज का राशिफल' : 'Today',
        text:
          language === 'hi'
            ? 'राशि नहीं मिली, इसलिए दैनिक फल नहीं खींच सके।'
            : 'Could not read a zodiac sign, so the daily prediction was skipped.',
      };
    }
    const today = new Date();
    const dateIso = `${today.getFullYear()}-${pad(today.getMonth() + 1)}-${pad(today.getDate())}T00:00:00+05:30`;
    const data = await prokeralaGet('/v2/horoscope/daily', {
      datetime: dateIso,
      sign,
    });
    const prediction = data?.daily_prediction?.prediction ?? pickText(data);
    return {
      title: language === 'hi' ? 'आज का राशिफल' : 'Today',
      text: prediction || (language === 'hi' ? 'फल नहीं मिला।' : 'No prediction returned.'),
    };
  }

  const kundli = await prokeralaGet('/v2/astrology/kundli', chartParams);
  const reading = sanitizeKundli(kundli, birth);
  return {
    title: language === 'hi' ? 'कुंडली सार' : 'Chart summary',
    text: formatReading(reading, language),
  };
}

function sanitizeKundli(data, birth) {
  const nak = data?.nakshatra_details ?? {};
  const yogas = Array.isArray(data?.yoga_details)
    ? data.yoga_details
        .map((item) => ({
          name: String(item?.name ?? ''),
          description: String(item?.description ?? ''),
        }))
        .filter((item) => item.name || item.description)
    : [];
  return {
    source: 'prokerala',
    placeLabel: birth.placeLabel,
    datetime: birth.datetime,
    nakshatra: named(nak.nakshatra),
    nakshatraPada: nak.nakshatra?.pada ?? null,
    nakshatraLord: named(nak.nakshatra?.lord) || nak.nakshatra?.lord?.vedic_name,
    chandraRasi: named(nak.chandra_rasi),
    sooryaRasi: named(nak.soorya_rasi),
    zodiac: named(nak.zodiac),
    mangalDosha: {
      hasDosha: Boolean(data?.mangal_dosha?.has_dosha),
      description: String(data?.mangal_dosha?.description ?? ''),
    },
    yogas,
  };
}

function formatReading(reading, language) {
  const hi = language === 'hi';
  const lines = [
    reading.nakshatra
      ? `${hi ? 'नक्षत्र' : 'Nakshatra'}: ${reading.nakshatra}`
      : null,
    reading.chandraRasi
      ? `${hi ? 'चंद्र राशि' : 'Moon sign'}: ${reading.chandraRasi}`
      : null,
    reading.sooryaRasi
      ? `${hi ? 'सूर्य राशि' : 'Sun sign'}: ${reading.sooryaRasi}`
      : null,
    reading.mangalDosha?.description ?? null,
    ...reading.yogas.map((yoga) => yoga.description || yoga.name),
  ].filter(Boolean);
  return lines.join('\n');
}

function formatCurrentDasha(data, language) {
  const periods = Array.isArray(data?.dasha_periods) ? data.dasha_periods : [];
  const now = Date.now();
  const maha = periods.find((period) => inRange(period, now));
  if (!maha) {
    return language === 'hi'
      ? 'वर्तमान महादशा नहीं मिली।'
      : 'No current mahadasha was returned.';
  }
  const antar = Array.isArray(maha.antardasha)
    ? maha.antardasha.find((period) => inRange(period, now))
    : null;
  if (language === 'hi') {
    return antar
      ? `महादशा ${maha.name}, अंतर्दशा ${antar.name}.`
      : `महादशा ${maha.name}.`;
  }
  return antar
    ? `Mahadasha ${maha.name}, antardasha ${antar.name}.`
    : `Mahadasha ${maha.name}.`;
}

function inRange(period, now) {
  const start = Date.parse(period?.start ?? '');
  const end = Date.parse(period?.end ?? '');
  return Number.isFinite(start) && Number.isFinite(end) && now >= start && now < end;
}

function tropicalSign(data) {
  const name = String(data?.nakshatra_details?.zodiac?.name ?? '')
    .trim()
    .toLowerCase();
  const allowed = new Set([
    'aries',
    'taurus',
    'gemini',
    'cancer',
    'leo',
    'virgo',
    'libra',
    'scorpio',
    'sagittarius',
    'capricorn',
    'aquarius',
    'pisces',
  ]);
  return allowed.has(name) ? name : null;
}

function named(value) {
  if (!value) {
    return null;
  }
  if (typeof value === 'string') {
    return value;
  }
  return value.name_hi || value.nameHi || value.name || value.vedic_name || null;
}

function pickText(data) {
  if (!data || typeof data !== 'object') {
    return '';
  }
  for (const key of ['description', 'prediction', 'details', 'summary']) {
    if (typeof data[key] === 'string' && data[key].trim()) {
      return data[key].trim();
    }
  }
  if (data.daily_prediction && typeof data.daily_prediction.prediction === 'string') {
    return data.daily_prediction.prediction.trim();
  }
  return '';
}

async function saveReading(uid, birth, reading) {
  const ref = db.collection('users').doc(uid).collection('astrology').doc('reading');
  await ref.set({
    ...reading,
    birth: {
      datetime: birth.datetime,
      coordinates: birth.coordinates,
      placeLabel: birth.placeLabel,
    },
    updatedAt: FieldValue.serverTimestamp(),
  });
}

async function bumpUsage(uid, field, limit) {
  const day = new Date().toISOString().slice(0, 10);
  const ref = db
    .collection('users')
    .doc(uid)
    .collection('astrology')
    .doc('usage')
    .collection('days')
    .doc(day);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = snap.exists ? Number(snap.get(field) || 0) : 0;
    if (current >= limit) {
      throw new HttpsError(
        'resource-exhausted',
        'Daily limit reached. Try again tomorrow.',
      );
    }
    tx.set(ref, { [field]: current + 1, day }, { merge: true });
  });
}

async function prokeralaGet(path, params) {
  const token = await accessToken();
  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === '') {
      continue;
    }
    search.set(key, String(value));
  }
  const response = await fetch(`${BASE}${path}?${search.toString()}`, {
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: 'application/json',
    },
  });
  const body = await response.json().catch(() => ({}));
  if (response.status === 401) {
    tokenCache = { value: '', expiresAt: 0 };
    throw new HttpsError('unauthenticated', 'Prokerala rejected the access token.');
  }
  if (response.status === 402 || response.status === 429) {
    throw new HttpsError(
      'resource-exhausted',
      'Prokerala credits or rate limit were hit.',
    );
  }
  if (!response.ok) {
    const detail = body?.errors?.[0]?.detail || body?.message || `HTTP ${response.status}`;
    throw new HttpsError('unavailable', String(detail).slice(0, 180));
  }
  return body.data ?? body;
}

async function accessToken() {
  if (tokenCache.value && Date.now() < tokenCache.expiresAt) {
    return tokenCache.value;
  }
  const id = secretValue(clientIdSecret, 'PROKERALA_CLIENT_ID');
  const secret = secretValue(clientSecretSecret, 'PROKERALA_CLIENT_SECRET');
  if (!id || !secret) {
    throw new HttpsError(
      'failed-precondition',
      'Prokerala credentials are not configured on the server.',
    );
  }
  const response = await fetch(`${BASE}/token`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'client_credentials',
      client_id: id,
      client_secret: secret,
    }),
  });
  const body = await response.json().catch(() => ({}));
  if (!response.ok || !body.access_token) {
    throw new HttpsError(
      'failed-precondition',
      'Prokerala did not issue an access token. Check the client id and secret.',
    );
  }
  const ttlMs = Math.max(30, Number(body.expires_in || 3600) - 60) * 1000;
  tokenCache = { value: body.access_token, expiresAt: Date.now() + ttlMs };
  return tokenCache.value;
}

function secretValue(param, envKey) {
  try {
    const value = param.value();
    if (value) {
      return String(value).trim();
    }
  } catch {
    // Emulator and local .env fall through to process.env.
  }
  return String(process.env[envKey] || '').trim();
}

function asInt(value) {
  const n = Number(value);
  return Number.isFinite(n) ? Math.trunc(n) : NaN;
}

function pad(n) {
  return String(n).padStart(2, '0');
}

function loadDotEnv() {
  for (const name of ['.env.local', '.env']) {
    const path = resolve(__dirname, name);
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

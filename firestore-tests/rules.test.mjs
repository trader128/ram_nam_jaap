/**
 * Rules tests for ../firestore.rules, run against the Firestore emulator.
 *
 *   cd firestore-tests && npm install && npm test
 *
 * These run entirely locally — no live project is touched. The point is to
 * prove that one anonymous device cannot reach another device's backup, since
 * anonymous sign-in is open by design and the rules are the only thing standing
 * between users.
 */
import { readFileSync } from 'node:fs';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc } from 'firebase/firestore';

const testEnv = await initializeTestEnvironment({
  projectId: 'bhakti-rules-test',
  firestore: {
    host: '127.0.0.1',
    port: 8080,
    rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
  },
});

const results = [];

async function check(name, promise) {
  try {
    await promise;
    results.push({ name, ok: true });
    console.log(`  PASS  ${name}`);
  } catch (error) {
    results.push({ name, ok: false, error });
    console.log(`  FAIL  ${name}\n        ${error.message}`);
  }
}

const alice = testEnv.authenticatedContext('alice').firestore();
const mallory = testEnv.authenticatedContext('mallory').firestore();
const anon = testEnv.unauthenticatedContext().firestore();

const snapshot = { schemaVersion: 1, japaStats: { ram: { lifetimeCount: 108 } } };

console.log('\nusers/{uid} — own backup');
await check(
  'a device can write its own backup',
  assertSucceeds(setDoc(doc(alice, 'users/alice'), snapshot)),
);
await check(
  'a device can read its own backup',
  assertSucceeds(getDoc(doc(alice, 'users/alice'))),
);

console.log('\nusers/{uid} — someone else\'s backup');
await check(
  'a device cannot read another user\'s backup',
  assertFails(getDoc(doc(mallory, 'users/alice'))),
);
await check(
  'a device cannot overwrite another user\'s backup',
  assertFails(setDoc(doc(mallory, 'users/alice'), { japaStats: {} })),
);
await check(
  'an unauthenticated client cannot read a backup',
  assertFails(getDoc(doc(anon, 'users/alice'))),
);
await check(
  'an unauthenticated client cannot write a backup',
  assertFails(setDoc(doc(anon, 'users/alice'), { japaStats: {} })),
);

console.log('\nshared content collections');
await check(
  'bhajans are publicly readable',
  assertSucceeds(getDoc(doc(alice, 'bhajans/hanuman-chalisa'))),
);
await check(
  'bhajans are not client-writable',
  assertFails(setDoc(doc(alice, 'bhajans/hanuman-chalisa'), { tier: 'free' })),
);
await check(
  'vrats are publicly readable',
  assertSucceeds(getDoc(doc(alice, 'vrats/ekadashi'))),
);
await check(
  'vrats are not client-writable',
  assertFails(setDoc(doc(alice, 'vrats/ekadashi'), { name: 'x' })),
);
await check(
  'panchang is publicly readable',
  assertSucceeds(getDoc(doc(alice, 'panchang/2026-08-24'))),
);
await check(
  'panchang is not client-writable',
  assertFails(
    setDoc(doc(alice, 'panchang/2026-08-24'), { date: '2026-08-24' }),
  ),
);

console.log('\ncollections not yet defined');
await check(
  'an undeclared collection is closed',
  assertFails(setDoc(doc(alice, 'orders/order-1'), { total: 0 })),
);
await check(
  'chat sessions are closed until Phase 5 defines them',
  assertFails(getDoc(doc(alice, 'chatSessions/session-1'))),
);

await testEnv.cleanup();

const failed = results.filter((result) => !result.ok);
console.log(
  `\n${results.length - failed.length}/${results.length} rules checks passed`,
);
process.exit(failed.length === 0 ? 0 : 1);

import { cp, rm } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('..', import.meta.url));
const dist = `${root}dist`;

await rm(dist, { recursive: true, force: true });
await cp(`${root}web`, dist, { recursive: true });
await cp(`${root}src`, `${dist}/src`, { recursive: true });

console.log('Built dist/');

// Pretty-prints Claude Code stream-json so you can watch an agent work.
import readline from 'node:readline';
import fs from 'node:fs';
const outFile = process.argv[2];
const c = (code, s) => `\x1b[${code}m${s}\x1b[0m`;
const short = (s, n = 110) => { s = String(s ?? '').replace(/\s+/g, ' ').trim(); return s.length > n ? s.slice(0, n) + '…' : s; };
let final = '';
readline.createInterface({ input: process.stdin })
  .on('line', (line) => {
    let ev; try { ev = JSON.parse(line); } catch { return; }
    if (ev.type === 'assistant') {
      for (const b of ev.message?.content ?? []) {
        if (b.type === 'text' && b.text.trim()) console.log('\n' + b.text.trim() + '\n');
        if (b.type === 'tool_use') {
          const i = b.input ?? {};
          const arg = i.file_path || i.path || i.pattern || i.command || i.description || '';
          console.log(`${c('1;34', '▸ ' + b.name)} ${c('2', short(arg))}`);
        }
      }
    } else if (ev.type === 'user') {
      for (const b of ev.message?.content ?? []) {
        if (b.type === 'tool_result' && b.is_error) {
          const t = typeof b.content === 'string' ? b.content : JSON.stringify(b.content);
          console.log(c('31', '  ✘ ' + short(t)));
        }
      }
    } else if (ev.type === 'result') {
      final = ev.result ?? '';
      console.log(c('1;32', `\n✔ finished in ${Math.round((ev.duration_ms ?? 0) / 1000)}s · ${ev.num_turns ?? '?'} turns`));
    }
  })
  .on('close', () => { if (outFile) fs.writeFileSync(outFile, final); });

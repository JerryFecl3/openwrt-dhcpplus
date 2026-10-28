const fs = require('node:fs');
const assert = require('node:assert/strict');
const path = require('node:path');
const source = fs.readFileSync(path.join(__dirname, '../package/luci-proto-dhcpplus/htdocs/luci-static/resources/protocol/dhcpplus.js'), 'utf8');
let state = { sendopts: ['0x0c:0102', '0x3c:0304', '0x7d:aa'] };
const uci = {
    get: (p, s, k) => state[k],
    set: (p, s, k, v) => { state[k] = v; },
    unset: (p, s, k) => { delete state[k]; }
};
const fields = {};
const form = { Value: {}, DummyValue: {}, ListValue: {}, Flag: {} };
const section = { taboption: (tab, type, name) => fields[name] = { tab, value() {}, depends() {} } };
const protocol = new Function('form', 'network', 'uci', '_', source)(form, {
    registerProtocol: (name, p) => { assert.equal(name, 'dhcpplus'); return p; }
}, uci, s => s);
protocol.renderFormOptions(section);
assert.equal(fields._option60, undefined);
assert.equal(fields.fixedxid, undefined);
assert.equal(fields._option12, undefined);
assert.equal(fields.hostname.default, '*');
assert.equal(fields.hostname.tab, 'advanced');
assert.equal(fields.hostname.datatype, 'or(hostname, "*")');
assert.deepEqual(state.sendopts, ['0x0c:0102', '0x3c:0304', '0x7d:aa']);
console.log('PASS: optional normal hostname, no raw authentication fields, rendering leaves UCI unchanged.');

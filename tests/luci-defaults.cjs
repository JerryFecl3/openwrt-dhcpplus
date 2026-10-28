const fs=require('fs'),assert=require('assert');
let proto;
new Function('network','form','_',fs.readFileSync('package/luci-proto-dhcpplus/htdocs/luci-static/resources/protocol/dhcpplus.js','utf8'))({registerProtocol:(n,p)=>proto=p},{},x=>x);
assert.equal(proto.getI18n(),'DHCP+');
for(const stored of [undefined,'0','1']){
 const options={};const s={taboption:(t,k,n)=>options[n]={value(){},depends(){}},getOption:n=>options[n],render(){return stored===undefined?options.defaultroute.default:stored;}};
 proto.renderFormOptions(s);
 options.defaultroute={default:'1'}; // Standard LuCI replaces this after protocol hook.
 assert.equal(s.render(),stored===undefined?'0':stored);
 assert.equal(options.defaultroute.rmempty,false);
}
console.log('Default gateway off; explicit 0/1 retained; protocol title passed');

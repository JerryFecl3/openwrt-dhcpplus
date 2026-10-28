"""Stage local APK roots. Run after building the helper for the target architecture."""
import argparse, pathlib, shutil, tarfile
p=argparse.ArgumentParser()
p.add_argument('--helper',required=True)
a=p.parse_args()
root=pathlib.Path(__file__).resolve().parents[1]
stage=root/'build'/'roots'
files=[
 ('core','lib/netifd/proto/dhcpplus.sh',root/'package/netifd-proto-dhcpplus/files/dhcpplus.sh',0o755),
 ('core','usr/lib/iptv/udhcpc-xid.so',pathlib.Path(a.helper),0o755),
 ('luci','www/luci-static/resources/protocol/dhcpplus.js',root/'package/luci-proto-dhcpplus/htdocs/luci-static/resources/protocol/dhcpplus.js',0o644),
]
for pkg,name,src,mode in files:
    target=stage/pkg/name; target.parent.mkdir(parents=True,exist_ok=True)
    data=src.read_bytes()
    if src.suffix in ('.sh','.js'): data=data.replace(b'\r\n',b'\n')
    target.write_bytes(data)
    target.chmod(mode)
with tarfile.open(root/'build'/'package-roots.tar.gz','w:gz') as tar:
    for pkg,name,src,mode in files:
        path=stage/pkg/name
        info=tar.gettarinfo(str(path),arcname=pkg+'/'+name)
        info.uid=info.gid=0; info.uname=info.gname='root'; info.mode=mode
        with path.open('rb') as f: tar.addfile(info,f)
print(root/'build'/'package-roots.tar.gz')

首次签名发行版，面向 OpenWrt 25.12 / x86_64。

- 包含 netifd-proto-dhcpplus 和 luci-proto-dhcpplus。
- 沿用已验证的 DHCP+ 运行逻辑；此次更新增加自动构建、APK 签名和软件源索引。
- 包安装/升级不主动重启网络、netifd 或已有 DHCP 客户端。新版本在下次接口启动时生效。
- 首次安装协议后，如 LuCI 尚未显示协议，可在合适的维护时间重新加载 netifd 或重启设备。
- 当前只验证特定 Option 60 格式，不承诺适用于所有运营商/地区。

安装说明见仓库 README 与 docs/publishing.md。软件源采用固定签名公钥，不需要 --allow-untrusted。

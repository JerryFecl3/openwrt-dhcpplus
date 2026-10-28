# 整理验收（2026-10-28）

源码基线：核心 0.3.0-r2、LuCI 0.3.0-r3。

- 两套 Node.js LuCI 测试通过，包括普通主机名、自动认证字段、默认网关默认关闭及用户显式设置保留。
- 整理不改变协议脚本或 C 辅助库行为。
- 排除真实线路抓包、现场维护脚本、截图和预编译共享库。
- 本次没有重新执行 OpenWrt runtime.sh、SDK 编译或真实续租测试。

首次使用其他固件、架构或线路，需独立验证启动、重传、续租与接口恢复。
# 签名发布验收（2026-10-28）

- v0.3.1 / 两个包均为 0.3.1-r1，OpenWrt 25.12 / x86_64。
- GitHub Actions 使用已校验 SHA256 的 OpenWrt 25.12.4 官方工具链完成编译和 APK 打包。
- 两项 LuCI 测试通过；两个包及 Packages.adb 均验签通过，空信任目录的反向测试正确拒绝索引。
- 公开 Pages 软件源经独立 CI 读取索引、按包名 fetch 两个包并验签成功；下载文件与 SHA256SUMS 一致。
- [签名发布运行](https://github.com/JerryFecl3/openwrt-dhcpplus/actions/runs/40649486065)
- [公开软件源验收](https://github.com/JerryFecl3/openwrt-dhcpplus/actions/runs/40649718951)
- 此次未在路由器安装或重启接口；真实线路运行结论沿用此前版本验证，不能把构建验签当作新增线路验收。


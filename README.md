# OpenWrt DHCP+

为 OpenWrt 增加 DHCP+ 协议选项，继续使用系统原版 udhcpc 和 netifd DHCP 脚本。

当前源码对应 `netifd-proto-dhcpplus 0.3.0-r2` 和 `luci-proto-dhcpplus 0.3.0-r3`。已验证环境为 OpenWrt 25.12 系列、x86_64/musl、辽宁联通的一条 IPTV 线路；不代表其他地区、运营商或架构已经兼容。

算法字段、合成测试向量、进程隔离、续租差异与证据边界见 [DHCP+ 协议与实现笔记](docs/protocol.md)。

## 工作方式

每次客户端启动生成随机非零 31 位 XID，并计算：

```text
Option60 = 00001f28 || SHA1(ASCII(十进制 XID + LUIOITDCNNCMPVHP))
```

小型共享库仅在相应 udhcpc 进程内接管 `rand()`，使 XID 与 Option60 配对。没有全局预加载，也不替换 BusyBox。摘要通过 `openssl-util` 计算。

算法常量属于协议实现，不是用户账号或密码。源码不包含设备固件、抓包或用户配置。

## 安装与使用

安装两个匹配架构的包。开发包未签名时，仅本次安装使用 `--allow-untrusted`：

```sh
apk add --allow-untrusted /tmp/netifd-proto-dhcpplus-0.3.0-r2.apk /tmp/luci-proto-dhcpplus-0.3.0-r3.apk
```

首次安装后 netifd 需要重新发现协议，请在维护窗口重启设备。插件不会自行重启全网。

在 LuCI 网络接口选择 **DHCP+**，指定正确的 IPTV 设备/VLAN。MAC、发送主机名按线路实际要求设置；不要让两个相同 MAC 的设备同时在线。新接口默认关闭“使用该接口的网关作为默认网关”；已有显式配置保持优先。Option60 无需填写，Option12 由普通主机名选项控制。取得地址不等于完成应用平台认证。

## 源码构建

将 `package/` 下两个目录复制至匹配目标固件的 OpenWrt SDK `package/` 中，运行：

```sh
make menuconfig
make package/netifd-proto-dhcpplus/compile V=s
make package/luci-proto-dhcpplus/compile V=s
```

SDK 用目标工具链编译 `src/udhcpc-xid.c`。本轮整理未重新执行完整 SDK 构建，其他架构须实测。

也可用 `python tools/stage.py --helper /path/to/udhcpc-xid.so` 配合 `tools/mkpkg.sh` 进行本地 APK 打包；辅助库必须由目标架构工具链构建，打包器须来自可信 OpenWrt 构建环境。

## 测试

在仓库根目录执行：

```sh
node tests/luci-fields.cjs
node tests/luci-defaults.cjs
```

OpenWrt 上可运行 `sh tests/runtime.sh package/netifd-proto-dhcpplus/files/dhcpplus.sh`，测试使用内存配置并替代 DHCP 启动函数，不发 DHCP 报文。运行测试不等同于真实线路续租验收。

## 发布范围

仅保留实现、通用测试和构建脚本。APK、共享库、现场维护脚本及历史抓包不进入 Git；编译产物可在验收后作为 Release 附件发布。许可证：MIT，见 LICENSE。

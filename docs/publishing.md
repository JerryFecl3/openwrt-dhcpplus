# 安装与发布

当前二进制软件源面向 OpenWrt 25.12、x86_64。其他架构可使用源码自行构建，尚未实测。

## 配置信任与软件源

在路由器上执行以下命令。先核验公钥文件 SHA256，再将其加入 APK 信任目录；无需 `--allow-untrusted`。

```sh
base='https://jerryfecl3.github.io/openwrt-dhcpplus/openwrt-25.12/x86_64'
wget -O /tmp/dhcpplus-public.pem "$base/dhcpplus-public.pem" &&
echo '801b02cf7ddbc3990ff92fae9a7281172285b080dbb30a65841b8b84a635e46b  /tmp/dhcpplus-public.pem' | sha256sum -c - &&
mkdir -p /etc/apk/keys /etc/apk/repositories.d &&
cp /tmp/dhcpplus-public.pem /etc/apk/keys/dhcpplus-public.pem &&
printf '%s\n' "$base/Packages.adb" > /etc/apk/repositories.d/dhcpplus.list
```

然后安装：

```sh
apk update
apk add luci-proto-dhcpplus
```

首次安装后 netifd 可能尚未发现新协议，请安排维护窗口重新加载 netifd 或重启设备。升级包不主动重启网络；运行中的 udhcpc 继续使用原来已加载的代码，下次接口启动才使用新版本。

后续升级：

```sh
apk update
apk upgrade netifd-proto-dhcpplus luci-proto-dhcpplus
```

“自动更新”在这里指软件源能向包管理器提供新版本；不会额外安装无人值守升级任务。

## 维护者发布流程

1. 修改两个 Makefile、tools/mkpkg.sh 中的包版本，以及 VERSION 和 release-notes.md。
2. 提交后推送 `v<VERSION>` 标签，或在 main 上手动运行 Signed APK release。
3. Actions 下载带固定 SHA256 的 OpenWrt 官方工具链和 Alpine 官方 APK 打包器，编译、测试、签名并验签。
4. 签名包、公钥、索引和 SHA256SUMS 上传 GitHub Release；同一批文件部署至 GitHub Pages。

私钥仅放仓库 Actions Secret `APK_SIGNING_KEY`，不提交源码。公开的 keys/dhcpplus-public.pem 与签名私钥必须匹配。发布流程使用固定 Actions commit SHA，不对 PR 执行带私钥的发布任务。

每个版本使用唯一标签；不要覆盖已经发布的包。失败后优先重跑失败的 job，已发布 Release 应先核对再处理，不能盲目覆盖。Pages 软件源只提供当前版本，历史版本保存在 Releases。

完整 SDK Makefile 构建路径与当前基于官方工具链的 APK 发布路径不同；当前发布流程未调用 SDK 通用安装脚本，因此不会附带自动服务重启钩子。

# 🛡️ Proxy Panel IP Cert

> 为代理面板打造的终极 IP 证书与伪装前置方案。

专为 `x-ui` / `3x-ui` / `s-ui` 等主流代理面板设计的自动化部署脚本。它通过 Caddy 接管服务器的 80 端口，完美实现了**防主动探测伪装**与**全自动 Let's Encrypt IP 证书签发/续签**的有机结合。

## ✨ 核心特性

- **🎭 流量分流与伪装**：Caddy 独占 80 端口。正常访客或扫描器会被 `301` 永久重定向到你设定的伪装域名（如 `www.tesla.com`），有效防范特征扫描。
- **🔐 纯净 IP 证书**：全自动调用 `acme.sh` 申请 Let's Encrypt 短效期 (Short-lived) ECC IP 证书，无需拥有域名即可开启 HTTPS/TLS 加密通道。
- **🤖 面板智能联动**：证书签发与续签完成后，自动检测并平滑重启主流代理面板（支持 `x-ui`, `3x-ui`, `s-ui`），确保底层核心（Xray/Sing-box）实时加载最新证书。
- **⏰ 赛博生物钟**：自动植入 Crontab 定时任务，每日凌晨 06:00 静默触发证书审查与自动续签，一次部署，终身免维护。

## ⚙️ 运行环境要求

- **操作系统**：Debian / Ubuntu（推荐使用纯净系统）
- **权限要求**：必须以 `root` 用户运行
- **网络要求**：服务器必须拥有公网 IPv4 地址
- **端口要求**：服务器的 **`80`** 端口必须处于空闲状态（不可被 Nginx, Apache 或面板直接占用）

## 🚀 一键部署

使用 SSH 登录到您的服务器，并以 `root` 身份执行以下命令：

```bash
bash <(curl -sL [https://raw.githubusercontent.com/starshine369/proxy-panel-ip-cert/main/install.sh](https://raw.githubusercontent.com/starshine369/proxy-panel-ip-cert/main/install.sh))

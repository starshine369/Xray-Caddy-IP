# 🛡️ VPS-Stealth: Caddy & LE-IP-Cert 

**毕业级富强服务器伪装方案。** 
本脚本专为“富强主力机”设计，通过 **Caddy (Port 80)** 与 **Port 443** 的物理隔离，实现完美的商业网站伪装。同时利用 **Let's Encrypt** 申请 7 天短效 IP 证书，彻底解决纯 IP 节点的 HTTPS 合规性问题。

**证书存放路径：**/opt/cert/ip/

## ✨ 方案亮点

| 核心组件 | 职责描述 | 伪装效果 |
| :--- | :--- | :--- |
| **Caddy (80)** | 守门人：处理 HTTP 验证与伪装 | 301 重定向至指定大厂域名 (如 Tesla) |
| **Xray (443)** | 核心：Reality 协议加密流量 | 白嫖大厂证书，TLS 指纹完美伪装 |
| **ACME (LE)** | 认证：Let's Encrypt IP 证书 | 7 天短效证书，凌晨 6:00 全自动续签 |

* **完全脱敏**：脚本运行过程中实时输入邮箱与伪装域名，不在脚本内留痕。
* **物理隔离**：80 端口与 443 端口互不干涉，不需要复杂的流量转发。
* **全自动续签**：针对 LE 短效证书优化的 `cron` 任务，自动完成验证、更新与重启。

---

## 🚀 快速开始

在您的纯净版 **Debian/Ubuntu** 系统上，以 root 用户执行以下指令：

```bash
curl -L https://raw.githubusercontent.com/starshine369/Xray-Caddy-IP/main/install.sh | bash

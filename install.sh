#!/bin/bash

# ====================================================
# Caddy伪装 + Let's Encrypt IP证书一键脚本
# ====================================================

set -e

# 0. Root 权限检查
if [[ $EUID -ne 0 ]]; then
   echo "❌ 错误：请以 root 权限运行此脚本！"
   exit 1
fi

# 1. 自动检测环境与 IP
echo "🔍 正在进行系统环境测绘..."
SERVER_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me)
if [ -z "$SERVER_IP" ]; then
    echo "❌ 错误：无法获取公网 IP，请检查网络连接。"
    exit 1
fi

# 2. 交互式获取信息 (增加 </dev/tty 以支持管道执行)
echo "----------------------------------------------------"
printf "📧 请输入您的联系邮箱 (用于注册 ACME 账号): "
read -r USER_EMAIL </dev/tty
printf "🌐 请输入伪装域名 [默认: www.tesla.com]: "
read -r FAKE_DOMAIN </dev/tty

FAKE_DOMAIN=${FAKE_DOMAIN:-www.tesla.com}

echo "----------------------------------------------------"
echo "🚀 目标 IP: $SERVER_IP"
echo "📧 联系邮箱: $USER_EMAIL"
echo "🌐 伪装目标: $FAKE_DOMAIN"
echo "----------------------------------------------------"
printf "确认以上信息无误？(y/n): "
read -r CONFIRM </dev/tty
if [ "$CONFIRM" != "y" ]; then
    echo "❌ 操作取消。"
    exit 1
fi

# 3. 环境依赖安装
echo "--- 正在安装环境依赖 ---"
apt update && apt install -y curl socat cron sudo debian-keyring debian-archive-keyring apt-transport-https

# 4. 安装 acme.sh 并注册账号
echo "--- 正在初始化 acme.sh 环境 ---"
curl https://get.acme.sh | sh -s email=$USER_EMAIL
# 强制锁定 Let's Encrypt 并注册
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --register-account -m $USER_EMAIL --server letsencrypt

# 5. 部署 Caddy 门卫
echo "--- 正在部署 Caddy 伪装防御体系 ---"
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
sudo apt update && sudo apt install caddy -y

sudo mkdir -p /var/www/acme
sudo cat > /etc/caddy/Caddyfile << EOF
:80 {
    # 豁免通道：给证书审查员开绿灯
    handle /.well-known/acme-challenge/* {
        root * /var/www/acme
        file_server
    }
    # 伪装通道
    handle {
        redir https://$FAKE_DOMAIN{uri} permanent
    }
}
EOF
sudo systemctl enable --now caddy
sudo systemctl restart caddy

# 6. 执行 IP 证书申请与安装
echo "--- 正在清理环境并申请 Let's Encrypt IP 证书 ---"
sudo mkdir -p /opt/cert/ip/

# 强制清理旧的证书文件，防止之前说的“重复追加”bug
sudo rm -f /opt/cert/ip/*.pem

# 申请证书 (添加了 Let's Encrypt IP 证书强制要求的短期配置参数)
/root/.acme.sh/acme.sh --issue -d $SERVER_IP \
--webroot /var/www/acme \
--server letsencrypt \
--certificate-profile shortlived \
--days 2 \
--force \
--ecc

# 物理提取并设置重启联动
/root/.acme.sh/acme.sh --install-cert -d $SERVER_IP --ecc \
--key-file       /opt/cert/ip/privkey.pem  \
--fullchain-file /opt/cert/ip/fullchain.pem \
--reloadcmd      "systemctl restart x-ui || systemctl restart 3x-ui || systemctl restart s-ui || echo 'No Panel Found'"

# 7. 校准凌晨 6:00 自动续签逻辑
echo "--- 正在校准自动续签逻辑 ---"
(crontab -l 2>/dev/null | grep -v "acme.sh" ; echo "0 6 * * * \"/root/.acme.sh\"/acme.sh --cron --home \"/root/.acme.sh\" > /dev/null") | crontab -

echo "----------------------------------------------------"
echo "✅ 部署完美结束！"
echo "🌐 伪装跳转: http://$SERVER_IP -> https://$FAKE_DOMAIN"
echo "🔐 证书路径: /opt/cert/ip/"
echo "----------------------------------------------------"

#!/bin/bash
LAN_IP="${1:-192.168.1.1}"
ENABLE_CCACHE="${2:-false}"
# 修改 LAN 默认 IP
sed -i "s/192\.168\.1\.1/${LAN_IP}/g" package/base-files/files/bin/config_generate
# 写入编译选项
cat >> .config <<'EOF'
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_coreutils-nohup=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_tailscale=y
CONFIG_PACKAGE_luci-app-store=y
EOF
[ "${ENABLE_CCACHE}" = "true" ] && echo "CONFIG_CCACHE=y" >> .config
echo "diy-part2.sh 完成，LAN IP=${LAN_IP}"

#!/bin/bash
#==============================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
#  N1 (S905D)   diy-part2.shfeeds 
#  IP OpenClash + Tailscale + iStore
# $1 = LAN IP 192.168.1.1
#       $2 = ccache "true" / "false"
#==============================================================================

#  1.  LAN IP 
default_ip="192.168.1.1"
ip_regex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
[[ -n "${1}" && "${1}" != "${default_ip}" && "${1}" =~ ${ip_regex} ]] && {
        echo ">>>  LAN IP ${1}"
            sed -i "/lan) ipad=\${ipaddr:-/s/\${ipaddr:-\"[^\"]*\"}/\${ipaddr:-\"${1}\"}/" \
                    package/base-files/*/bin/config_generate
                    }
                    
                    #  2. autocore  armsr-armv8 
                    sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armsr/g' \
                        package/lean/autocore/Makefile
                        
                        #  3.  
                        sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" \
                            package/lean/default-settings/files/zzz-default-settings
                            echo "DISTRIB_SOURCEREPO='github.com/coolsnowwolf/lede'" >> package/base-files/files/etc/openwrt_release
                            echo "DISTRIB_SOURCECODE='lede'"                         >> package/base-files/files/etc/openwrt_release
                            echo "DISTRIB_SOURCEBRANCH='master'"                     >> package/base-files/files/etc/openwrt_release
                            
                            #  4. ccache $2 
                            sed -i '/CONFIG_DEVEL/d;/CONFIG_CCACHE/d' .config
                            if [[ "${2}" == "true" ]]; then
                                echo "CONFIG_DEVEL=y"                         >> .config
                                    echo "CONFIG_CCACHE=y"                        >> .config
                                        echo 'CONFIG_CCACHE_DIR="$(TOPDIR)/.ccache"' >> .config
                                            echo ">>> ccache "
                                            else
                                                echo "# CONFIG_DEVEL is not set"              >> .config
                                                    echo "# CONFIG_CCACHE is not set"             >> .config
                                                        echo 'CONFIG_CCACHE_DIR=""'                   >> .config
                                                        fi
                                                        
                                                        #  5.  luci-app-amlogicAmlogic 
                                                        echo ">>>  luci-app-amlogic ..."
                                                        rm -rf package/luci-app-amlogic
                                                        git clone -b main --depth=1 https://github.com/ophub/luci-app-amlogic.git \
                                                            package/luci-app-amlogic
                                                            
                                                            # 
                                                            #  A OpenClash
                                                            # 
                                                            echo ">>>  OpenClash ..."
                                                            
                                                            grep -q "passwall_packages" feeds.conf.default || \
                                                                echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" \
                                                                    >> feeds.conf.default
                                                                    
                                                                    rm -rf package/luci-app-openclash
                                                                    git clone -b dev --depth=1 https://github.com/vernesong/OpenClash.git \
                                                                        package/luci-app-openclash
                                                                        
                                                                        ./scripts/feeds update -i
                                                                        ./scripts/feeds install -a -p passwall_packages 2>/dev/null || true
                                                                        ./scripts/feeds install luci-app-openclash      2>/dev/null || true
                                                                        
                                                                        cat >> .config >> 'OPENCLASH_CONFIG'
                                                                        
                                                                        #  OpenClash +  
                                                                        CONFIG_PACKAGE_luci-app-openclash=y
                                                                        CONFIG_PACKAGE_coreutils=y
                                                                        CONFIG_PACKAGE_coreutils-nohup=y
                                                                        CONFIG_PACKAGE_curl=y
                                                                        CONFIG_PACKAGE_ca-certificates=y
                                                                        CONFIG_PACKAGE_ca-bundle=y
                                                                        CONFIG_PACKAGE_bash=y
                                                                        CONFIG_PACKAGE_libcap=y
                                                                        CONFIG_PACKAGE_libcap-bin=y
                                                                        CONFIG_PACKAGE_iptables-mod-tproxy=y
                                                                        CONFIG_PACKAGE_iptables-mod-extra=y
                                                                        CONFIG_PACKAGE_kmod-ipt-tproxy=y
                                                                        CONFIG_PACKAGE_kmod-nft-tproxy=y
                                                                        CONFIG_PACKAGE_kmod-tun=y
                                                                        CONFIG_PACKAGE_ip-full=y
                                                                        CONFIG_PACKAGE_ipset=y
                                                                        CONFIG_PACKAGE_iptables=y
                                                                        CONFIG_PACKAGE_ip6tables=y
                                                                        CONFIG_PACKAGE_kmod-ipt-nat6=y
                                                                        CONFIG_PACKAGE_dnsmasq-full=y
                                                                        # CONFIG_PACKAGE_dnsmasq is not set
                                                                        CONFIG_PACKAGE_ruby=y
                                                                        CONFIG_PACKAGE_ruby-yaml=y
                                                                        OPENCLASH_CONFIG
                                                                        echo ">>> OpenClash "
                                                                        
                                                                        # 
                                                                        #  B Tailscale
                                                                        # 
                                                                        echo ">>>  Tailscale ..."
                                                                        
                                                                        rm -rf package/luci-app-tailscale
                                                                        git clone -b main --depth=1 https://github.com/asvow/luci-app-tailscale.git \
                                                                            package/luci-app-tailscale
                                                                            
                                                                            ./scripts/feeds update -i
                                                                            ./scripts/feeds install tailscale          2>/dev/null || true
                                                                            ./scripts/feeds install luci-app-tailscale 2>/dev/null || true
                                                                            
                                                                            cat >> .config >> 'TAILSCALE_CONFIG'
                                                                            
                                                                            #  Tailscale  + LuCI 
                                                                            CONFIG_PACKAGE_tailscale=y
                                                                            CONFIG_PACKAGE_luci-app-tailscale=y
                                                                            CONFIG_PACKAGE_kmod-wireguard=y
                                                                            CONFIG_PACKAGE_wireguard-tools=y
                                                                            CONFIG_PACKAGE_iptables-mod-conntrack-extra=y
                                                                            TAILSCALE_CONFIG
                                                                            echo ">>> Tailscale "
                                                                            
                                                                            # 
                                                                            #  C iStoreLinkEase 
                                                                            # 
                                                                            echo ">>>  iStore ..."
                                                                            
                                                                            grep -q "istore" feeds.conf.default || \
                                                                                echo "src-git istore https://github.com/linkease/istore-ui.git" \
                                                                                    >> feeds.conf.default
                                                                                    
                                                                                    grep -q "istore_pkg" feeds.conf.default || \
                                                                                        echo "src-git istore_pkg https://github.com/linkease/istore.git;main" \
                                                                                            >> feeds.conf.default
                                                                                            
                                                                                            ./scripts/feeds update -i
                                                                                            ./scripts/feeds install -a -p istore_pkg 2>/dev/null || true
                                                                                            ./scripts/feeds install luci-app-store   2>/dev/null || true
                                                                                            
                                                                                            cat >> .config >> 'ISTORE_CONFIG'
                                                                                            
                                                                                            #  iStore  +  
                                                                                            CONFIG_PACKAGE_luci-app-store=y
                                                                                            CONFIG_PACKAGE_taskd=y
                                                                                            CONFIG_PACKAGE_luci-lib-taskd=y
                                                                                            CONFIG_PACKAGE_luci-lib-xterm=y
                                                                                            ISTORE_CONFIG
                                                                                            echo ">>> iStore "
                                                                                            
                                                                                            # 
                                                                                            #  D
                                                                                            # 
                                                                                            echo ">>>  ..."
                                                                                            
                                                                                            cat >> .config >> 'BLOATWARE_REMOVE'
                                                                                            
                                                                                            #   N1  
                                                                                            # CONFIG_PACKAGE_luci-app-ssr-plus is not set
                                                                                            # CONFIG_PACKAGE_luci-app-passwall is not set
                                                                                            # CONFIG_PACKAGE_luci-app-passwall2 is not set
                                                                                            # CONFIG_PACKAGE_luci-app-turboacc is not set
                                                                                            # CONFIG_PACKAGE_luci-app-vlmcsd is not set
                                                                                            # CONFIG_PACKAGE_luci-app-vsftpd is not set
                                                                                            # CONFIG_PACKAGE_luci-app-minidlna is not set
                                                                                            # CONFIG_PACKAGE_luci-app-transmission is not set
                                                                                            # CONFIG_PACKAGE_luci-app-accesscontrol is not set
                                                                                            # CONFIG_PACKAGE_luci-app-arpbind is not set
                                                                                            # CONFIG_PACKAGE_luci-app-wol is not set
                                                                                            # CONFIG_PACKAGE_luci-app-nlbwmon is not set
                                                                                            # CONFIG_PACKAGE_luci-app-ddns is not set
                                                                                            # CONFIG_PACKAGE_ddns-scripts_aliyun is not set
                                                                                            # CONFIG_PACKAGE_ddns-scripts_dnspod is not set
                                                                                            # CONFIG_PACKAGE_luci-theme-material is not set
                                                                                            # CONFIG_PACKAGE_luci-theme-argon is not set
                                                                                            # CONFIG_PACKAGE_luci-theme-netgear is not set
                                                                                            BLOATWARE_REMOVE
                                                                                            
                                                                                            echo ">>> diy-part2.sh  "}
}
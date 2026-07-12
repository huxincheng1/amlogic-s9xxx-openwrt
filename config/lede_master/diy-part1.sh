#!/bin/bash
# 添加 OpenClash 包
git clone --depth 1 https://github.com/vernesong/OpenClash /tmp/openclash
cp -rf /tmp/openclash/luci-app-openclash package/
rm -rf /tmp/openclash
# 添加 iStore 包
git clone --depth 1 https://github.com/linkease/istore /tmp/istore
cp -rf /tmp/istore/luci-app-store package/
rm -rf /tmp/istore
echo "diy-part1.sh 完成"

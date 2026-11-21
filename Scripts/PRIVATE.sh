#!/bin/bash
# SPDX-License-Identifier: MIT
# =================================================================
# 私有扩展脚本 (由 Packages.sh 自动加载)
# 此文件独立于上游仓库，上游更新永远不会冲突或覆盖！
# =================================================================

echo "=== 执行用户私有扩展脚本 PRIVATE.sh ==="

# 1. 安装 Lucky (端口转发/反向代理/DDNS全能工具)
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main"

# 2. 安装 TurboACC (适配 Firewall4 与高通 NSS 满血硬件加速)
UPDATE_PACKAGE "turboacc" "chenmozhijin/turboacc" "luci" "pkg"

# 3. 剔除 EasyTier 等非必要 VPN 目录 (确保系统仅保留 ZeroTier)
rm -rf ./package/luci-app-easytier ./package/easytier 2>/dev/null || true

# 4. 移除 LuCI 系统菜单中空置的“插件”页面 (admin/system/plugins)
SYSTEM_MENU_JSON="./feeds/luci/modules/luci-mod-system/root/usr/share/luci/menu.d/luci-mod-system.json"
if [ -f "$SYSTEM_MENU_JSON" ]; then
	jq 'del(."admin/system/plugins")' "$SYSTEM_MENU_JSON" > "${SYSTEM_MENU_JSON}.tmp" && \
		mv -f "${SYSTEM_MENU_JSON}.tmp" "$SYSTEM_MENU_JSON"
	rm -f ./feeds/luci/modules/luci-mod-system/htdocs/luci-static/resources/view/system/plugins.js
	echo "Removed empty admin/system/plugins menu and view."
fi

# 5. 仅保留中文：移除 LuCI 英文语言包定义并将默认界面语言锁定为 zh_cn
if [ -f "./feeds/luci/luci.mk" ]; then
	sed -i '/^LUCI_LANG\.en=/d' ./feeds/luci/luci.mk
fi
LUCI_CFG="./feeds/luci/modules/luci-base/root/etc/config/luci"
if [ -f "$LUCI_CFG" ]; then
	sed -i "s/option lang '.*'/option lang 'zh_cn'/g" "$LUCI_CFG"
fi

# 6. 修复第三方插件 po/zh-cn 与 po/zh_Hans 目录名不兼容导致缺失中文语言包显示英文的问题
find ./package/ ./feeds/luci/ -type d -name "po" 2>/dev/null | while read -r PO_DIR; do
	if [ -d "$PO_DIR/zh-cn" ] && [ ! -e "$PO_DIR/zh_Hans" ]; then
		ln -sf zh-cn "$PO_DIR/zh_Hans"
	elif [ -d "$PO_DIR/zh_Hans" ] && [ ! -e "$PO_DIR/zh-cn" ]; then
		ln -sf zh_Hans "$PO_DIR/zh-cn"
	fi
done

# 刷新包扫描缓存，确保 make defconfig 重新加载修改后的 luci.mk 与 po 语言目录
rm -rf ./tmp/.packageinfo ./tmp/.config-package.in 2>/dev/null || true

echo "=== 用户私有扩展脚本 PRIVATE.sh 执行完毕 ==="

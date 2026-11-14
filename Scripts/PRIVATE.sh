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

echo "=== 用户私有扩展脚本 PRIVATE.sh 执行完毕 ==="

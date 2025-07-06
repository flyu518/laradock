#!/bin/bash

source ./utils.sh

echo "🛑 正在检查并关闭 Redis 集群节点..."
if ! stop_redis_node "${DEFAULT_PORTS[@]}"; then
  echo "❌ Redis节点关闭失败，中止脚本"
  exit 1
fi

echo "清空数据"
clear

echo "✅ 操作完成"
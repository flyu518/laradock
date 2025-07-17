#!/bin/bash -e

source ./utils.sh

# 检查节点状态
echo "检查 Redis 实例启动..."
if ! check_redis_node "${DEFAULT_PORTS[@]}"; then
  echo "❌ Redis节点检查失败，中止脚本"
  exit 1
fi
echo "✅ 所有 Redis 实例已启动"

# 检查集群状态
echo "检查集群启动..."
if ! check_redis_cluster "${DEFAULT_PORT}"; then
  echo "❌ 集群状态检查失败，中止脚本"
  exit 1
fi
echo "集群已启动"

# 列出所有节点
show_nodes "${DEFAULT_PORT}"


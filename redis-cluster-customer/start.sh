#!/bin/bash -e

# 引入公共函数
source ./utils.sh

# 启动 Redis 实例
echo "Redis 实例启动..."
if ! create_redis_node "${DEFAULT_PORTS[@]}"; then
  echo "❌ Redis 实例启动失败，中止脚本"
  exit 1
fi


# 创建集群
echo "创建集群..."
if ! create_redis_cluster "${DEFAULT_IP}" "${DEFAULT_PORTS[@]}"; then
  echo "❌ 集群创建失败，中止脚本"
  exit 1
fi

# 列出所有节点
echo "列出所有节点..."
show_nodes "${DEFAULT_PORT}"


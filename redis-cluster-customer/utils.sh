#!/bin/bash -e

# 获取本机ip（下面需要获取，需要放在最上面）
get_local_ip() {
  if command -v ip >/dev/null 2>&1; then
    ip addr show | awk '/inet / && $2 !~ /^127/ { sub(/\/.*/, "", $2); print $2; exit }'
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig | awk '/inet / && $2 != "127.0.0.1" { print $2; exit }'
  else
    echo "无法获取 IP（系统无 ip/ifconfig 命令）" >&2
    return 1
  fi
}

DEFAULT_IP="${DEFAULT_IP:-$(get_local_ip)}" # 外面可以覆盖
DEFAULT_PORTS=(6380 6381 6382 6383 6384 6385)
DEFAULT_PORT=6380
DEFAULT_PASSWORD=123456

# 创建 redis 节点，参数：port1 port2 port3 port4 port5 port6
create_redis_node() {
  local ports=("$@") # 把所有节点地址组成数组
  if [[ "${#ports[@]}" -lt 6 ]]; then
    echo "❌ 至少需要 6 个节点（3 主 3 从），当前仅传入 ${#ports[@]} 个"
    return 1
  fi

  echo "⏳ 正在创建 Redis 节点：${ports[*]}"

  for port in "${ports[@]}"; do
    redis-server ./"${port}"/redis.conf &
  done

  # 检查之前需要先暂停一下，否则会有问题
  sleep 1

  # 检查一下状态
  check_redis_node "${ports[@]}"

  return $?
}

# 创建集群，参数：ip port1 port2 port3 port4 port5 port6
create_redis_cluster() {
  local ip="$1"
  shift # 除去第一个
  local ports=("$@") # 把所有节点地址组成数组
  if [[ "${#ports[@]}" -lt 6 ]]; then
    echo "❌ 至少需要 6 个节点（3 主 3 从），当前仅传入 ${#ports[@]} 个"
    return 1
  fi

  # 拼接 ip:port 形式
  local nodes=()
  for port in "${ports[@]}"; do
    nodes+=("${ip}:${port}")
  done

  echo "⏳ 正在创建 Redis 集群，节点：${nodes[*]}"

  yes yes | redis-cli -a "$DEFAULT_PASSWORD" \
    --cluster create "${nodes[@]}" \
    --cluster-replicas 1

  sleep 1

  # 检查一下状态
  if ! check_redis_cluster "${ports[0]}" ; then
    echo "❌ 集群状态检查失败"
    return 1
  fi
}

# 检查 redis 节点，参数：port1 port2 port3 port4 port5 port6
check_redis_node() {
  local ports=("$@") # 把所有节点地址组成数组
  if [[ "${#ports[@]}" -lt 6 ]]; then
    echo "❌ 至少需要 6 个节点（3 主 3 从），当前仅传入 ${#ports[@]} 个"
    return 1
  fi

  echo "⏳ 正在检测 Redis 节点：${ports[*]}"

  for port in "${ports[@]}"; do
    if ! check_redis_node_single "$port"; then
      echo "❌ Redis $port 启动失败"
      return 1
    fi
  done
}

# 检查 redis 单点状态，参数：port （被检测的端口）
check_redis_node_single() {
  local port=$1
  local retries=30
  echo "⏳ 检测 Redis $port 是否就绪..."

  while true; do
    # 使用 perl 不直接使用 redis-cli ping 是因为如果端口没有启动，直接执行会卡着
    command perl -e 'alarm shift; exec @ARGV' 1 redis-cli -a "$DEFAULT_PASSWORD" -h "$DEFAULT_IP" -p "$port" ping >/dev/null 2>&1
    local code=$?

    if [[ $code -eq 0 ]]; then
      echo "✅ Redis $port 响应正常"
      return 0
    fi

    retries=$((retries - 1))
    if [[ $retries -le 0 ]]; then
      echo "❌ Redis $port 无法响应 ping"
      return 1
    fi

    sleep 0.1
  done
}

# 检查集群状态，参数：port（一个端口就行）
check_redis_cluster() {
  local port=${1:-$DEFAULT_PORT}
  cluster_info=$(redis-cli -a "$DEFAULT_PASSWORD" -c -h "$DEFAULT_IP" -p "$port" cluster info 2>/dev/null)
  if echo "$cluster_info" | grep -q "cluster_state:ok"; then
    echo "✅ Redis 集群状态正常："
    echo "$cluster_info" | grep "cluster_state"
    return 0
  else
    echo "❌ Redis 集群启动失败，请检查日志或配置。"
    echo "$cluster_info"
    return 1
  fi
}

# 关闭 redis 节点，参数：port1 port2 port3 port4 port5 port6
stop_redis_node() {
  local ports=("$@") # 把所有节点地址组成数组
  if [[ "${#ports[@]}" -lt 6 ]]; then
    echo "❌ 至少需要 6 个节点（3 主 3 从），当前仅传入 ${#ports[@]} 个"
    return 1
  fi

  echo "⏳ 正在关闭 Redis 节点：${ports[*]}"

  # 检查一下状态
  for port in "${ports[@]}"; do
    if check_redis_node_single "$port"; then
      echo "🔻 正在关闭 Redis 实例 $port"
      redis-cli -a "$DEFAULT_PASSWORD" -h "$DEFAULT_IP" -p "$port" shutdown
    else
      echo "⚠️ 端口 $port 无响应，可能未启动"
    fi
  done
}

# 显示节点列表，参数：port（一个端口就行）
show_nodes() {
  local port=${1:-$DEFAULT_PORT}
  echo "📋 节点列表（ID 地址 角色）："
  redis-cli -a "$DEFAULT_PASSWORD" -c -h "$DEFAULT_IP" -p "$port" cluster nodes | awk '{print $1, $2, $3}'
}

# 清空数据
clear() {
  rm -f 638*/nodes.conf
  rm -f 638*/appendonly.aof
  rm -f 638*/dump.rdb
}

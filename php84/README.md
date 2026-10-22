# PHP 8.4 开发环境

新增 `php-fpm-84`、`workspace-84`，与现有 PHP 7.2、7.4 服务并存。
两者使用与 nongfu 相同的 `web/nginx-php:v3.2.1` 固定摘要，PHP 为 8.4.27，
当前支持 `linux/amd64`（Apple Silicon 通过 Docker Desktop 模拟运行）。
Dockerfile 覆盖基础镜像入口，FPM 只运行 PHP-FPM，workspace 只保持命令行容器运行。
底层为 Alpine Linux，安装系统工具使用 `apk`。

## 构建与使用

在 laradock 根目录执行：

```bash
docker compose build php-fpm-84 workspace-84
docker compose up -d --no-deps php-fpm-84 workspace-84
docker compose exec workspace-84 bash
```

需要安装系统包时，可用 `docker compose exec -u root workspace-84 bash` 进入管理员终端。

`workspace-84` 默认是 `laradock` 普通用户，UID/GID 沿用 `WORKSPACE_PUID`、
`WORKSPACE_PGID`，工作目录及代码挂载沿用 `APP_CODE_PATH_*`。
包含 Composer 2.10.3、Git、SSH 客户端、Vim、zip/unzip；当前旧 workspace 未启用
Node 安装，新服务也不包含 Node/Yarn、Docker-in-Docker 或 SSH 服务端。

例如检查 nongfu：

```bash
docker compose exec -w /var/www/nongfu workspace-84 php -v
docker compose exec -w /var/www/nongfu workspace-84 composer check-platform-reqs
docker compose exec -w /var/www/nongfu workspace-84 composer test:compatibility
```

只有显式指定服务或启用 `php84` profile 时才会启动新版；`.env` 的 `PHP_VERSION=7.2`、
现有启动脚本和 Nginx 站点配置不需要全局切换。
需要让某个站点使用 8.4 时，先启动 `php-fpm-84`，再将该站点的 PHP location 改为：

```nginx
fastcgi_pass php-fpm-84:9000;
```

验证 `nginx -t` 后重载 Nginx。其他站点仍可指向 `php-fpm` 或 `php-fpm-74`。

## 扩展及配置

保留基础镜像的 MongoDB 2.5.5、Redis、Imagick 3.8.1、GD、intl、EXIF、ZIP、
MySQL/PostgreSQL 驱动、pcntl、sockets、igbinary、OPcache 等扩展；
补充 bcmath、FTP（含 TLS）、msgpack 3.0.1、memcached 3.4.0、AST 1.1.3、
SSH2 1.5.0 和 Xdebug 3.5.3。PHP 8.4 不提供 WDDX。

- `php.ini`：两个服务共同使用，内存 256M，上传 20M、POST 25M，隐藏 PHP 版本。CA 沿用基础镜像构建时更新的系统证书，容器启动时不自动更新。
- `php-fpm.conf`：监听内部 9000 端口，按需创建进程，最多 5 个，FPM 强制超时为 0。PHP 执行时间限制保持开发环境的 600 秒。本机 amd64 模拟环境不支持 FPM 慢请求堆栈所需的 `ptrace`，默认关闭慢堆栈采集；原生 amd64 环境可按需开启。
- `workspace.ini`：CLI 执行时间为 0，不限制常驻脚本运行时长；单个脚本可用 `php -d memory_limit=512M ...` 调整自己的内存。
- 两个容器默认各有 768M 内存上限，可通过 `.env` 中的 `PHP84_FPM_MEMORY_LIMIT`、`PHP84_WORKSPACE_MEMORY_LIMIT` 调整；这不等于 PHP 单请求内存限制。

以上配置通过 Compose 只读挂载，修改 PHP/FPM 配置后重启对应新容器即可。
需要改变 UID/GID、工具或扩展时重新构建镜像。

Xdebug 已安装，默认关闭。需要调试时在 `.env` 设置：

```dotenv
PHP84_XDEBUG_MODE=debug,develop
PHP84_XDEBUG_CLIENT_PORT=9001
```

执行 `docker compose up -d --no-deps php-fpm-84 workspace-84` 更新环境变量，
IDE 监听所设端口，并通过 `XDEBUG_TRIGGER=1` 环境变量或同名 Cookie/查询参数触发。
IDE 路径映射使用容器的 `/var/www` 对应宿主机的 `APP_CODE_PATH_HOST`。
调试连接由容器向宿主机发起，不需要为 FPM 映射 Xdebug 入站端口。

## 验证记录

2026-10-23 已在当前 Docker Desktop 环境完成以下检查：

| 检查 | 结果 |
| --- | --- |
| 两个镜像构建、FPM 配置校验 | 通过 |
| CLI/FPM 扩展及 15 项功能检查 | 通过，两端扩展版本一致 |
| Nginx 转发 FPM、7 秒请求、隐藏 PHP 响应头 | 通过 |
| Xdebug DBGp 连接、系统 CA 的真实 HTTPS 校验 | 通过 |
| nongfu 平台依赖及离线兼容检查 | 29 项通过 |
| 实际 Compose 启动、普通用户写入代码挂载、正常停止 | 通过 |

与旧 workspace 的实际扩展列表对比，仅 WDDX 不再提供，新增 APCu、Imagick、random、SSH2。
原有 102 个服务定义保持一致。验证后已删除新建的测试容器，仅保留两个交付镜像；
需要使用时按上面的 `up` 命令启动。

本次本地验证记录位于 `php84/validation/2026-10-23/`，该目录不纳入版本控制。

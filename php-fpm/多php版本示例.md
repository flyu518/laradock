# 多 PHP 版本使用

默认 `workspace` 和 `php-fpm` 从 `.env` 的 `PHP_VERSION` 选择版本，当前默认是 `8.4`。具体补丁版本由 Laradock 基础镜像决定，可用 `php -v` 查看。

从旧 `.env` 升级时，同步设置 `PHP_VERSION=8.4` 和 `WORKSPACE_AST_VERSION=1.1.2`，其余扩展开关继续沿用现有配置。

## 默认 PHP 8.4

```shell
docker compose build workspace php-fpm
./start_service.sh
docker compose exec workspace php -v
docker compose exec php-fpm php -v
```

普通站点沿用 `fastcgi_pass php-upstream;`，默认 upstream 指向 `php-fpm:9000`。

## 临时 PHP 7.2

已保留固定版本的 `workspace-72`、`php-fpm-72`，无需改动默认 `PHP_VERSION`。

```shell
docker compose build workspace-72 php-fpm-72
docker compose up -d workspace-72 php-fpm-72
docker compose exec workspace-72 php -v
```

这两个临时服务不发布宿主机端口，可与默认服务同时运行。CLI 使用 `workspace-72`；需要 PHP 7.2 的站点将 PHP location 中的一行改为：

```nginx
fastcgi_pass php-fpm-72:9000;
```

修改站点后检查并重载 Nginx：

```shell
docker compose exec nginx nginx -t
docker compose exec nginx nginx -s reload
```

使用完毕后，将站点恢复为 `fastcgi_pass php-upstream;` 并重载 Nginx，再停止临时服务：

```shell
docker compose stop php-fpm-72 workspace-72
```

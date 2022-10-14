ARG VER_NGINX=1.23.1
ARG BITNAMI_NGINX_REVISION=r2
ARG BITNAMI_NGINX_TAG=${VER_NGINX}-debian-11-${BITNAMI_NGINX_REVISION}

FROM bitnami/nginx:${BITNAMI_NGINX_TAG} AS builder
USER root

# build schema variables
# http://label-schema.org/rc1/
ARG BUILD_DATE
ENV BUILD_DATE=$BUILD_DATE
ARG VCS_REF
ENV VCS_REF=$VCS_REF

# ngx_devel_kit
# https://github.com/vision5/ngx_devel_kit/releases
# The NDK is now considered to be stable.
ARG VER_NGX_DEVEL_KIT=0.3.1
ENV VER_NGX_DEVEL_KIT=$VER_NGX_DEVEL_KIT

# headers-more-nginx-module
# https://github.com/openresty/headers-more-nginx-module/tags
ARG VER_OPENRESTY_HEADERS=0.34
ENV VER_OPENRESTY_HEADERS=$VER_OPENRESTY_HEADERS

# lua version
# https://github.com/lua/lua/releases
ARG VER_LUA=5.4
ENV VER_LUA=$VER_LUA

# luajit2
# https://github.com/openresty/luajit2/tags
# Note: LuaJIT2 is stuck on Lua 5.1 since 2009.
ARG VER_LUAJIT=2.1-20220411
ENV VER_LUAJIT=$VER_LUAJIT
ARG LUAJIT_LIB=/usr/local/lib
ENV LUAJIT_LIB=$LUAJIT_LIB
ARG LUAJIT_INC=/usr/local/include/luajit-2.1
ENV LUAJIT_INC=$LUAJIT_INC
ARG LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH

# lua-nginx-module
# https://github.com/openresty/lua-nginx-module/tags
# Production ready.
# TODO: Restore to 0.10.xx as the v0.10.21 has a bug fixed in commit b6d167cf1a93c0c885c28db5a439f2404874cb26
ARG VER_LUA_NGINX_MODULE=cff86dd7f677e3b856fb7ca1de90746b24eb6411
ENV VER_LUA_NGINX_MODULE=$VER_LUA_NGINX_MODULE

# lua-resty-core
# https://github.com/openresty/lua-resty-core/tags
# This library is production ready.
# TODO: Restore to 0.1.xx as the v0.1.23 has a bug fixed in commit 79f520183bb5b1a278d8a8be3f53659737232253
ARG VER_LUA_RESTY_CORE=79f520183bb5b1a278d8a8be3f53659737232253
ENV VER_LUA_RESTY_CORE=$VER_LUA_RESTY_CORE
ARG LUA_LIB_DIR=/usr/local/share/lua/5.4
ENV LUA_LIB_DIR=$LUA_LIB_DIR

# lua-resty-lrucache
# https://github.com/openresty/lua-resty-lrucache/tags
# This library is considered production ready.
ARG VER_LUA_RESTY_LRUCACHE=0.13
ENV VER_LUA_RESTY_LRUCACHE=$VER_LUA_RESTY_LRUCACHE

# lua-rocks
# https://luarocks.github.io/luarocks/releases/
ARG VER_LUAROCKS=3.9.1
ENV VER_LUAROCKS=$VER_LUAROCKS

# nginx-lua-prometheus
# https://github.com/knyar/nginx-lua-prometheus/tags
ARG VER_PROMETHEUS=0.20220527
ENV VER_PROMETHEUS=$VER_PROMETHEUS

# stream-lua-nginx-module
# https://github.com/openresty/stream-lua-nginx-module/commits/master
# TODO: Restore to 0.0.xx as the v0.0.11 has a bug fixed in commit 9ce0848cff7c3c5eb0a7d5adfe2de22ea98e1e63
ARG VER_OPENRESTY_STREAMLUA=9ce0848cff7c3c5eb0a7d5adfe2de22ea98e1e63
ENV VER_OPENRESTY_STREAMLUA=$VER_OPENRESTY_STREAMLUA

# https://github.com/bitnami/nginx/releases
ARG VER_NGINX=1.23.1
ENV VER_NGINX=$VER_NGINX
# References:
#  - https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc
#  - https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
# -g                        Generate debugging information
# -O2                       Recommended optimizations
# -fstack-protector-strong  Stack smashing protector
# -Wformat                  Check calls to make sure that the arguments supplied have types appropriate to the format string specified
# -Werror=format-security   Reject potentially unsafe format string arguents
# -Wp,-D_FORTIFY_SOURCE=2   Run-time buffer overflow detection
# -fPIC                     No text relocations
ARG NGX_CFLAGS="-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC"
ENV NGX_CFLAGS=$NGX_CFLAGS
# References
#  - https://developers.redhat.com/blog/2018/03/21/compiler-and-linker-flags-gcc
#  - https://wiki.debian.org/ToolChain/DSOLinking#Unresolved_symbols_in_shared_libraries
#  - https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_node/ld_3.html
#  - https://linux.die.net/man/1/ld
# -Wl,-rpath,/usr/local/lib   Add a directory to the runtime library search path
# -Wl,-z,relro                Read-only segments after relocation
# -Wl,-z,now                  Disable lazy binding
# -Wl,--as-needed             Only link with needed libraries
# -pie                        Full ASLR for executables
ARG NGX_LDOPT="-Wl,-rpath,/usr/local/lib -Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie"
ENV NGX_LDOPT=$NGX_LDOPT
# Reference: http://nginx.org/en/docs/configure.html
ARG NGINX_BUILD_CONFIG="\
            --prefix=/opt/bitnami/nginx \
            --sbin-path=/opt/bitnami/nginx/sbin/nginx \
            --modules-path=/opt/bitnami/nginx/modules \
            --conf-path=/opt/bitnami/nginx/conf/nginx.conf \
            --error-log-path=/opt/bitnami/nginx/logs/error.log \
            --http-log-path=/opt/bitnami/nginx/logs/access.log \
            --pid-path=/opt/bitnami/nginx/tmp/nginx.pid \
            --lock-path=/opt/bitnami/nginx/tmp/nginx.lock \
            --http-client-body-temp-path=/opt/bitnami/nginx/tmp/client_temp \
            --http-proxy-temp-path=/opt/bitnami/nginx/tmp/proxy_temp \
            --http-fastcgi-temp-path=/opt/bitnami/nginx/tmp/fastcgi_temp \
            --http-uwsgi-temp-path=/opt/bitnami/nginx/tmp/uwsgi_temp \
            --http-scgi-temp-path=/opt/bitnami/nginx/tmp/scgi_temp \
            --user=www \
            --group=www \
            --with-compat \
            --with-file-aio \
            --with-threads \
            --with-http_addition_module \
            --with-http_auth_request_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_mp4_module \
            --with-http_random_index_module \
            --with-http_realip_module \
            --with-http_secure_link_module \
            --with-http_slice_module \
            --with-http_ssl_module \
            --with-http_stub_status_module \
            --with-http_sub_module \
            --with-http_v2_module \
            --with-stream \
            --with-stream_realip_module \
            --with-stream_ssl_module \
            --with-stream_ssl_preread_module \
            --add-module=/lua-nginx-module-${VER_LUA_NGINX_MODULE} \
            --add-module=/ngx_devel_kit-${VER_NGX_DEVEL_KIT} \
            --add-module=/headers-more-nginx-module-${VER_OPENRESTY_HEADERS} \
            --add-module=/stream-lua-nginx-module-${VER_OPENRESTY_STREAMLUA} \
"
ENV NGINX_BUILD_CONFIG=$NGINX_BUILD_CONFIG

ARG BUILD_DEPS_BASE="\
        ca-certificates \
        curl \
        g++ \
        libgeoip-dev \
        libpcre3-dev \
        libssl-dev \
        lua${VER_LUA} \
        lua${VER_LUA}-dev \
        make \
        patch \
        unzip \
        zlib1g-dev \
        libperl-dev \
"
ENV BUILD_DEPS_BASE=$BUILD_DEPS_BASE

ARG NGINX_BUILD_DEPS="\
        curl \ 
"
ENV NGINX_BUILD_DEPS=$NGINX_BUILD_DEPS

ENV DEBIAN_FRONTEND noninteractive

## Install required packages and build dependencies
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        apt-utils \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        $BUILD_DEPS_BASE \
        $NGINX_BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

COPY Makefile Makefile

RUN make deps \
    && make core \
    && make luarocks

FROM bitnami/nginx:${BITNAMI_NGINX_TAG}

USER root

# Redeclare LUA version
ARG VER_LUA=5.4
ENV VER_LUA=$VER_LUA

# Install lua system package dependencies
ARG PKG_DEPS="\
        ca-certificates \
        libgeoip-dev \
        libpcre3-dev \
        libssl-dev \
        lua${VER_LUA} \
        lua${VER_LUA}-dev \
        zlib1g-dev \
"
ENV PKG_DEPS=$PKG_DEPS

RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends --no-install-suggests \
        $PKG_DEPS \
# Fix LUA alias
    && ln -sf /usr/bin/lua${VER_LUA} /usr/local/bin/lua \
# Bring in curl for debugging purposes
    && apt-get install -y --no-install-recommends --no-install-suggests curl ca-certificates \
# Upgrade software to latest version
    && apt-get upgrade -y \
# Cleanup
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Install from builder
COPY --from=builder --chown=1001:1001 /opt/bitnami/nginx/sbin/nginx /opt/bitnami/nginx/sbin/nginx
COPY --from=builder --chown=1001:1001 /usr/local/lib /usr/local/lib
COPY --from=builder --chown=1001:1001 /usr/local/share/lua /usr/local/share/lua
COPY --from=builder --chown=1001:1001 /usr/local/bin/luarocks /usr/local/bin/luarocks
COPY --from=builder --chown=1001:1001 /usr/local/etc/luarocks /usr/local/etc/luarocks

# Install modified conf files
COPY --chown=1001:1001 conf/nginx.conf /opt/bitnami/nginx/conf/nginx.conf
COPY --chown=1001:1001 conf/conf.d/default.conf /opt/bitnami/nginx/conf/server_blocks/default.conf

# Create symlinks to default locations for easy config checking
RUN set -eux \
    && rm -rf /etc/nginx \
    && ln -s /opt/bitnami/nginx/conf /etc/nginx

# Set the container to be run as a non-root user by default
USER 1001

# Override stop signal to stop process gracefully
STOPSIGNAL SIGQUIT

CMD ["/opt/bitnami/nginx/sbin/nginx", "-g", "daemon off;"]
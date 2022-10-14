NPROC := $(shell nproc)

# ##############################################################################
# CORE
# ##############################################################################

core:
# Bitnami NGINX
# ##############################################################################
## Download NGINX and extract
	cd /tmp && \
	curl -O http://nginx.org/download/nginx-${VER_NGINX}.tar.gz && \
	tar xzf nginx-${VER_NGINX}.tar.gz
## Compile NGINX with desired module
	cd /tmp/nginx-${VER_NGINX} && \
	rm -rf /opt/bitnami/nginx && \
	./configure ${NGINX_BUILD_CONFIG} --with-cc-opt="$(NGX_CFLAGS)" --with-ld-opt="$(NGX_LDOPT)" && \
	make -j $(NPROC) build && \
	make -j $(NPROC) modules && \
	make -j $(NPROC) install

# ##############################################################################
# DEPENDENCIES
# ##############################################################################

deps: dep-ngx_devel_kit dep-luajit dep-lua-nginx dep-lua-resty-core dep-headers-more-nginx-module dep-nginx-lua-prometheus dep-stream-lua-nginx-module dep-lua-resty-lrucache

# NGX Devel Kit
# ##############################################################################
dep-ngx_devel_kit:
	curl -sLo /ngx_devel_kit.tar.gz https://github.com/vision5/ngx_devel_kit/archive/v${VER_NGX_DEVEL_KIT}.tar.gz
	tar -C / -xvzf /ngx_devel_kit.tar.gz

# Lua Nginx Module
# ##############################################################################
dep-lua-nginx:
	curl -sLo /lua-nginx.tar.gz https://github.com/openresty/lua-nginx-module/archive/${VER_LUA_NGINX_MODULE}.tar.gz
	tar -C / -xvzf /lua-nginx.tar.gz

# LUA Resty Core
# ##############################################################################
dep-lua-resty-core:
	curl -sLo /lua-resty-core.tar.gz https://github.com/openresty/lua-resty-core/archive/${VER_LUA_RESTY_CORE}.tar.gz
	tar -C / -xvzf /lua-resty-core.tar.gz
	cd /lua-resty-core-${VER_LUA_RESTY_CORE} \
	&& make \
	&& make install

# LUA Resty LRUCache
# ##############################################################################
dep-lua-resty-lrucache:
	curl -sLo /lua-resty-lrucache.tar.gz https://github.com/openresty/lua-resty-lrucache/archive/v${VER_LUA_RESTY_LRUCACHE}.tar.gz
	tar -C / -xvzf /lua-resty-lrucache.tar.gz
	cd /lua-resty-lrucache-${VER_LUA_RESTY_LRUCACHE} \
	&& make \
	&& make install

# OpenResty LUAJIT2
# ##############################################################################
dep-luajit:
	curl -sLo /luajit.tar.gz https://github.com/openresty/luajit2/archive/v${VER_LUAJIT}.tar.gz
	tar -C / -xvzf /luajit.tar.gz
	cd /luajit2-${VER_LUAJIT} \
	&& make \
	&& make install
# This is because OpenResty LuaJIT2 is stuck on Lua 5.1 since 2009.
# Also, since LUA_LIB_DIR is set on 5.4, the 5.1 folder is always empty and nginx
# will try to look things in the wrong one, unless provided with:
#  lua_package_path '/usr/local/share/lua/5.4/?.lua;;';
#  lua_package_cpath '/usr/local/lib/lua/5.4/?.so;;';
# it is safe to delete the folders as they have JUST been created
	rm -r /usr/local/lib/lua/5.1 /usr/local/share/lua/5.1
	ln -s /usr/local/lib/lua/5.4 /usr/local/lib/lua/5.1
	ln -s /usr/local/share/lua/5.4 /usr/local/share/lua/5.1

# OpenResty Headers
# ##############################################################################
dep-headers-more-nginx-module:
	curl -sLo /headers-more-nginx-module.zip https://github.com/openresty/headers-more-nginx-module/archive/v${VER_OPENRESTY_HEADERS}.zip
	unzip -d / /headers-more-nginx-module.zip

# OpenResty Stream Lua
# ##############################################################################
dep-stream-lua-nginx-module:
	curl -sLo /stream-lua-nginx-module.zip https://github.com/openresty/stream-lua-nginx-module/archive/${VER_OPENRESTY_STREAMLUA}.zip
	unzip -d / /stream-lua-nginx-module.zip

# Prometheus
# ##############################################################################
dep-nginx-lua-prometheus:
	curl -sLo /nginx-lua-prometheus.tar.gz https://github.com/knyar/nginx-lua-prometheus/archive/${VER_PROMETHEUS}.tar.gz
	tar -C / -xvzf /nginx-lua-prometheus.tar.gz
	mv /nginx-lua-prometheus-${VER_PROMETHEUS}/*.lua ${LUA_LIB_DIR}/

# ##############################################################################
# LUAROCKS
# ##############################################################################

luarocks:
	curl -sLo /luarocks.tar.gz https://luarocks.org/releases/luarocks-${VER_LUAROCKS}.tar.gz
	tar -C / -xzvf /luarocks.tar.gz
	cd /luarocks-${VER_LUAROCKS}; \
	./configure \
	&& make \
	&& make install

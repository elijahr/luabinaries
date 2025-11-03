# HASHES: https://www.lua.org/ftp/

# Discover all Lua tarballs in the repository
LUA_TARBALLS := $(wildcard lua-*.tar.gz)
LUA_VERSIONS := $(patsubst lua-%.tar.gz,%,$(LUA_TARBALLS))

# Function to convert version to short name (5.1.5 -> lua51)
# Extract major.minor and convert dots to nothing
short_name = lua$(shell echo $(1) | cut -d. -f1)$(shell echo $(1) | cut -d. -f2)

# Create lists of short names for each platform
LINUX_TARGETS := $(foreach v,$(LUA_VERSIONS),$(call short_name,$(v)))
WINDOWS_TARGETS := $(foreach v,$(LUA_VERSIONS),$(addsuffix -windows,$(call short_name,$(v))))
MACOS_TARGETS := $(foreach v,$(LUA_VERSIONS),$(addsuffix -macos,$(call short_name,$(v))))

.PHONY: all linux windows macos clean $(LINUX_TARGETS) $(WINDOWS_TARGETS) $(MACOS_TARGETS)

all: linux windows macos

linux: $(LINUX_TARGETS)

windows: $(WINDOWS_TARGETS)

macos: $(MACOS_TARGETS)

# Build function for Linux (using musl for static binaries)
define build_lua_linux
	$(info Building $(1))
	mkdir -p build/linux
	rm -rf $(1)
	tar xf $(1).tar.gz
	sed -i -e 's/^CC=/CC?=/' -e 's/^LIBS=/LIBS?=/' -e 's/^CFLAGS=/CFLAGS?=/' -e 's/^LDFLAGS=/LDFLAGS?=/' $(1)/src/Makefile
	@cd $(1) && CC="musl-gcc" CFLAGS="-O3 -static -fPIC" LDFLAGS="-static" LIBS="" make posix
	@strip $(1)/src/luac $(1)/src/lua
endef

# Build function for Windows (cross-compile with MinGW)
define build_lua_win64
	$(info Building $(1))
	mkdir -p build/win64
	rm -rf $(1)
	tar xf $(1).tar.gz
	sed -i -e 's/^CC=/CC?=/' -e 's/^LIBS=/LIBS?=/' -e 's/^CFLAGS=/CFLAGS?=/' -e 's/^LDFLAGS=/LDFLAGS?=/' $(1)/src/Makefile
	bash stamp-exe.sh "$(1)" > lua.rc
	x86_64-w64-mingw32-windres lua.rc -O coff -o $(1)/src/lua.res
	rm -r lua.rc
	@cd $(1) && \
	CC="$(shell which x86_64-w64-mingw32-gcc)" \
	LD="$(shell which x86_64-w64-mingw32-ld)" \
	AR="$(shell which x86_64-w64-mingw32-ar)" \
	RANLIB="$(shell which x86_64-w64-mingw32-ranlib)" \
	CFLAGS="-O3 -mthreads" \
	LDFLAGS=" -L/usr/x86_64-w64-mingw32/lib" \
	LIBS="lua.res -l:libm.a -l:libpthread.a -lssp" \
	make mingw
	@x86_64-w64-mingw32-strip $(1)/src/luac.exe $(1)/src/lua.exe
endef

# Build function for macOS (native build with Clang)
define build_lua_macos
	$(info Building $(1))
	mkdir -p build/macos
	rm -rf $(1)
	tar xf $(1).tar.gz
	sed -i '' -e 's/^CC=/CC?=/' -e 's/^LIBS=/LIBS?=/' -e 's/^CFLAGS=/CFLAGS?=/' -e 's/^LDFLAGS=/LDFLAGS?=/' $(1)/src/Makefile
	@cd $(1) && CC="clang" CFLAGS="-O3" LDFLAGS="" LIBS="" make macosx
	@strip $(1)/src/luac $(1)/src/lua
endef

# Template to generate Linux build targets
define LINUX_template
$(call short_name,$(1)):
	$$(call build_lua_linux,lua-$(1))
	@mv lua-$(1)/src/lua build/linux/$$(call short_name,$(1))
	@mv lua-$(1)/src/luac build/linux/luac$$(shell echo $(1) | cut -d. -f1)$$(shell echo $(1) | cut -d. -f2)
	@rm -rf lua-$(1)
endef

# Template to generate Windows build targets
define WINDOWS_template
$(call short_name,$(1))-windows:
	-$$(call build_lua_win64,lua-$(1))
	-@mv lua-$(1)/src/lua.exe build/win64/$$(call short_name,$(1)).exe
	-@mv lua-$(1)/src/luac.exe build/win64/luac$$(shell echo $(1) | cut -d. -f1)$$(shell echo $(1) | cut -d. -f2).exe
	-@mv lua-$(1)/src/lua$$(shell echo $(1) | cut -d. -f1)$$(shell echo $(1) | cut -d. -f2).dll build/win64/lua$$(shell echo $(1) | cut -d. -f1)$$(shell echo $(1) | cut -d. -f2).dll 2>/dev/null || true
	@rm -rf lua-$(1)
endef

# Template to generate macOS build targets
define MACOS_template
$(call short_name,$(1))-macos:
	$$(call build_lua_macos,lua-$(1))
	@mv lua-$(1)/src/lua build/macos/$$(call short_name,$(1))
	@mv lua-$(1)/src/luac build/macos/luac$$(shell echo $(1) | cut -d. -f1)$$(shell echo $(1) | cut -d. -f2)
	@rm -rf lua-$(1)
endef

# Generate all targets dynamically from discovered tarballs
$(foreach v,$(LUA_VERSIONS),$(eval $(call LINUX_template,$(v))))
$(foreach v,$(LUA_VERSIONS),$(eval $(call WINDOWS_template,$(v))))
$(foreach v,$(LUA_VERSIONS),$(eval $(call MACOS_template,$(v))))

clean:
	rm -rf build

# Luabinaries

This repository houses the most recent stable versions of the Lua language and creates static binaries ready to download and run.

We aim to create Lua interpreters that are optimized, compact and can run on most Lua supported platforms.

## Supported Platforms

- **Linux amd64** (x86 64-bit) - Static binaries using musl - filename pattern `luaVV`
- **Windows amd64** (x86 64-bit) - MinGW builds - filename pattern `luaVV.exe`
- **macOS amd64** (x86 64-bit) - Native builds - filename pattern `luaVV`
## Download

Direct download to our released binaries is possible using the following links:

### Linux amd64
- Lua 5.1: https://github.com/dyne/luabinaries/releases/latest/download/lua51
- Lua 5.3: https://github.com/dyne/luabinaries/releases/latest/download/lua53
- Lua 5.4: https://github.com/dyne/luabinaries/releases/latest/download/lua54

### Windows amd64
- Lua 5.1: https://github.com/dyne/luabinaries/releases/latest/download/lua51.exe
- Lua 5.3: https://github.com/dyne/luabinaries/releases/latest/download/lua53.exe
- Lua 5.4: https://github.com/dyne/luabinaries/releases/latest/download/lua54.exe

### macOS amd64
- Lua 5.1: https://github.com/dyne/luabinaries/releases/latest/download/lua51
- Lua 5.3: https://github.com/dyne/luabinaries/releases/latest/download/lua53
- Lua 5.4: https://github.com/dyne/luabinaries/releases/latest/download/lua54

Lua bytecode compilers are available simply by changing the file name to `luacVV` (or `luacVV.exe` for Windows).

Releases are tagged with the GitHub hash and listed in the [Release page](https://github.com/dyne/luabinaries/releases/).

## Building

The [Makefile](https://github.com/dyne/luabinaries/blob/main/Makefile) automatically discovers and builds all Lua versions found in the repository. It scans for `lua-*.tar.gz` files and dynamically generates build targets - no hardcoded versions needed!

### How It Works

The Makefile:
1. **Auto-discovers** all Lua tarballs in the repository root
2. **Generates build targets** automatically (e.g., `lua-5.4.8.tar.gz` → `lua54` target)
3. **Builds for multiple platforms** - Linux, Windows, macOS
4. **No manual updates needed** - just add new tarballs and build!

### Linux and Windows Builds

To build Linux and Windows binaries on a Linux system, install the required dependencies:

```bash
sudo apt-get install -y make musl musl-tools gcc-mingw-w64
```

Then build:
```bash
make linux    # Build Linux binaries
make windows  # Build Windows binaries
make          # Build all platforms (Linux, Windows, macOS)
```

### macOS Builds

To build macOS binaries on a macOS system:

```bash
make macos    # Build macOS binaries only
```

**Note:** On macOS, use `make macos` specifically. The `make linux` and `make windows` targets require Linux-specific tools (musl-gcc, MinGW) and will not work on macOS.

### Output Structure

The builds create optimized binaries in the `build/` directory organized by platform:
- `build/linux/` - Linux amd64 binaries (e.g., `lua51`, `lua53`, `lua54`)
- `build/win64/` - Windows amd64 binaries (e.g., `lua51.exe`, `lua53.exe`, `lua54.exe`)
- `build/macos/` - macOS amd64 binaries (e.g., `lua51`, `lua53`, `lua54`)

### Adding New Lua Versions

To add support for a new Lua version:
1. Download the tarball: `curl -O https://www.lua.org/ftp/lua-X.Y.Z.tar.gz`
2. Run `make` - the new version will be built automatically!

No Makefile modifications required.

The versions of the released binaries are listed below, the respective sources are available at https://lua.org/ftp:

- lua-5.1.5.tar.gz (Feb 13  2012) `7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88`
- lua-5.3.6.tar.gz (Sep 14  2020) `fc5fd69bb8736323f026672b1b7235da613d7177e72558893a0bdcd320466d60`
- lua-5.4.8.tar.gz (May 21  2025) `4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae`

### Build Optimizations

- **Linux**: Static binaries built with [Musl](https://musl.libc.org/) for portability
- **Windows**: Cross-compiled using MinGW
- **macOS**: Native builds using Clang

The released binaries are compressed to ~50% of their original size using [UPX](https://upx.github.io/).

### Automated Builds

The GitHub Actions workflow automatically builds binaries for all three platforms:
- Linux and Windows builds run on Ubuntu using musl and MinGW cross-compilation
- macOS builds run natively on macOS runners
- All builds are compressed and packaged with SHA256 checksums
- Releases are automatically created and tagged with the git commit hash

### Automated Version Updates

A weekly scheduled workflow checks for new Lua releases:
- Compares current tarballs against latest versions from https://www.lua.org/ftp/
- Automatically downloads new versions when available
- Creates a pull request with updated tarballs and checksums
- The dynamic Makefile automatically builds the new versions - no code changes needed!

## Acknowledgements

This is not an "official" distribution of Lua binaries.

Lua is Copyright © 1994–2023 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


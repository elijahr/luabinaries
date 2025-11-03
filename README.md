# Luabinaries

This repository houses the most recent stable versions of the Lua language and creates static binaries ready to download and run.

We aim to create Lua interpreters that are optimized, compact and can run on most Lua supported platforms.

## Supported Platforms

Each platform provides both the Lua interpreter and the Lua bytecode compiler (luac).

| Platform | Architecture | Interpreter       | Compiler           | Notes                           |
| -------- | ------------ | ----------------- | ------------------ | ------------------------------- |
| Linux    | x64          | `luaVV`           | `luacVV`           | Static binaries built with musl |
| Windows  | x64          | `luaVV.exe`       | `luacVV.exe`       | Cross-compiled with MinGW       |
| macOS    | x64          | `luaVV-macos-x64` | `luacVV-macos-x64` | Native builds with Clang        |

*VV = Lua version (51, 53, or 54)*

## Download

Download the latest binaries from the [Releases page](https://github.com/dyne/luabinaries/releases/latest), or use direct links below:

### Linux

| Lua Version | Interpreter                                                                 | Compiler                                                                      |
| ----------- | --------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| 5.1         | [lua51](https://github.com/dyne/luabinaries/releases/latest/download/lua51) | [luac51](https://github.com/dyne/luabinaries/releases/latest/download/luac51) |
| 5.3         | [lua53](https://github.com/dyne/luabinaries/releases/latest/download/lua53) | [luac53](https://github.com/dyne/luabinaries/releases/latest/download/luac53) |
| 5.4         | [lua54](https://github.com/dyne/luabinaries/releases/latest/download/lua54) | [luac54](https://github.com/dyne/luabinaries/releases/latest/download/luac54) |

### Windows

| Lua Version | Interpreter                                                                         | Compiler                                                                              |
| ----------- | ----------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| 5.1         | [lua51.exe](https://github.com/dyne/luabinaries/releases/latest/download/lua51.exe) | [luac51.exe](https://github.com/dyne/luabinaries/releases/latest/download/luac51.exe) |
| 5.3         | [lua53.exe](https://github.com/dyne/luabinaries/releases/latest/download/lua53.exe) | [luac53.exe](https://github.com/dyne/luabinaries/releases/latest/download/luac53.exe) |
| 5.4         | [lua54.exe](https://github.com/dyne/luabinaries/releases/latest/download/lua54.exe) | [luac54.exe](https://github.com/dyne/luabinaries/releases/latest/download/luac54.exe) |

### macOS

| Lua Version | Interpreter                                                                                     | Compiler                                                                                          |
| ----------- | ----------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| 5.1         | [lua51-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/lua51-macos-x64) | [luac51-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/luac51-macos-x64) |
| 5.3         | [lua53-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/lua53-macos-x64) | [luac53-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/luac53-macos-x64) |
| 5.4         | [lua54-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/lua54-macos-x64) | [luac54-macos-x64](https://github.com/dyne/luabinaries/releases/latest/download/luac54-macos-x64) |

## Building

**On Linux:**

Make sure you installed the dependencies needed for building:

```
sudo apt-get install -y make musl musl-tools gcc-mingw-w64
```

The [Makefile](https://github.com/dyne/luabinaries/blob/main/Makefile) does everything needed using the original Lua source-code releases archived in this repository.

```
make linux    # Build Linux binaries
make windows  # Build Windows binaries (cross-compile)
make          # Build all (Linux, Windows, macOS)
```

**On macOS:**

```
make macos    # Build macOS binaries
```

Binaries are built to `build/linux/`, `build/win64/`, and `build/macos/` respectively.

The versions of the released binaries are listed below, the respective sources are available at https://lua.org/ftp:

- lua-5.1.5.tar.gz (Feb 13 2012) `7d5ea1b9cb6aa0b59ca3dde1c6adcb57ef83a1ba8e5432c0ecd06bf439b3ad88`
- lua-5.3.6.tar.gz (Sep 14 2020) `fc5fd69bb8736323f026672b1b7235da613d7177e72558893a0bdcd320466d60`
- lua-5.4.8.tar.gz (May 21 2025) `4f18ddae154e793e46eeab727c59ef1c0c0c2b744e7b94219710d76f530629ae`

To build static binaries ready to run everywhere, we use [Musl](https://musl.libc.org/).

The released binaries are compressed to ~50% of their original size using [upx-ucl](https://upx.github.io/).

## CI/CD

GitHub Actions automatically builds binaries for all three platforms:

- **linux-x64**: Static binaries built with musl on Ubuntu
- **windows-x64**: Cross-compiled with MinGW on Ubuntu
- **macos-x64**: Native builds on macOS runners

Releases are automatically created and tagged with the git commit hash.

## Acknowledgements

This is not an "official" distribution of Lua binaries.

Lua is Copyright © 1994–2023 Lua.org, PUC-Rio.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

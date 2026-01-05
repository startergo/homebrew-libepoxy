# homebrew-libepoxy

[![Build Status](https://img.shields.io/github/actions/workflow/status/startergo/homebrew-libepoxy/bottle.yml?branch=master&label=bottle%20build&logo=github&style=flat-square)](https://github.com/startergo/homebrew-libepoxy/actions/workflows/bottle.yml)

Homebrew tap for [libepoxy](https://github.com/anholt/libepoxy) - OpenGL function pointer management library for macOS builds with EGL support via [ANGLE](https://chromium.googlesource.com/angle/angle).

## What is libepoxy?

libepoxy is a library for handling OpenGL function pointer management for OpenGL, EGL, GLX, and WGL. It provides a modern replacement for GLUT with per-header function pointer management, ensuring you get the right API extensions for your context.

## Installation

```bash
# Tap the repository
brew tap startergo/libepoxy

# Install libepoxy (will also install startergo/angle/angle as dependency)
brew install startergo/libepoxy/libepoxy
```

## Usage

### Compile and link with pkg-config

```bash
# Compile
gcc -o myapp myapp.c $(pkg-config --cflags --libs epoxy)

# Or for CMake
find_package(PkgConfig REQUIRED)
pkg_check_modules(EPOXY REQUIRED epoxy)
include_directories(${EPOXY_INCLUDE_DIRS})
target_link_libraries(myapp ${EPOXY_LIBRARIES})
```

### Manual compile flags

```bash
# Include paths
-I$(brew --prefix libepoxy)/include

# Library paths
-L$(brew --prefix libepoxy)/lib

# Libraries
-lepoxy
```

## What's Included

- **Shared library**: `libepoxy.dylib`
- **Headers**: OpenGL, EGL, and GLX headers via epoxy
- **pkg-config file**: `epoxy.pc`

## Build Configuration

This build is configured for macOS with ANGLE backend:
- **EGL support via ANGLE**: Uses [startergo/angle](https://github.com/startergo/homebrew-angle) for OpenGL ES on macOS
- GLX support enabled (for X11 compatibility)
- X11 platform disabled (macOS native)
- Tests disabled for faster builds
- Builds against upstream libepoxy HEAD with macOS EGL patches applied

## License

MIT

## Upstream

This tap combines two upstream projects:

- **[libepoxy](https://github.com/anholt/libepoxy)**: OpenGL function pointer management library
- **[ANGLE](https://chromium.googlesource.com/angle/angle)**: OpenGL ES implementation for macOS (via [startergo/homebrew-angle](https://github.com/startergo/homebrew-angle))

The upstream libepoxy project last released in 2022 (v1.5.10). This tap builds against the latest upstream HEAD with macOS-specific patches to enable EGL support through ANGLE.

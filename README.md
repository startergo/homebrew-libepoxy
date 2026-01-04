# homebrew-libepoxy

Homebrew tap for [libepoxy](https://github.com/anholt/libepoxy) - OpenGL function pointer management library.

## What is libepoxy?

libepoxy is a library for handling OpenGL function pointer management for OpenGL, EGL, GLX, and WGL. It provides a modern replacement for GLUT with per-header function pointer management, ensuring you get the right API extensions for your context.

## Installation

```bash
# Tap the repository
brew tap startergo/libepoxy

# Install libepoxy
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

This build is configured for macOS:
- GLX support enabled (for X11 compatibility)
- EGL support enabled
- X11 platform disabled (macOS native)
- Tests disabled for faster builds

## License

MIT

## Upstream

- [libepoxy Project](https://github.com/anholt/libepoxy)

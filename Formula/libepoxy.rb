class Libepoxy < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  license "MIT"

  version "1.0.4"
  url "https://github.com/startergo/homebrew-libepoxy/archive/refs/tags/v1.0.4.tar.gz"
  sha256 "c6b3ba278f0047705ddf02234c78070f99c2040753f00b038132572cdfdcf641"
  head "https://github.com/anholt/libepoxy.git",
       using: :git

  bottle do
    root_url "https://github.com/startergo/homebrew-libepoxy/releases/download/v1.0.4"
    sha256 cellar: :any, arm64_sequoia: "8787cc8c34921834665262dff4941216dd6717edddf2c6d5cdfe04f03b24c517"
  end

  depends_on "startergo/angle/angle"
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  def install
    # Download upstream libepoxy source (HEAD from anholt/libepoxy)
    upstream_commit = "1b6d7db184bb1a0d9af0e200e06a0331028eaaae"
    upstream_url = "https://github.com/anholt/libepoxy/archive/#{upstream_commit}.tar.gz"
    ohai "Downloading upstream libepoxy from #{upstream_url}"
    system "curl", "-L", upstream_url, "-o", "libepoxy.tar.gz"
    system "tar", "-xzf", "libepoxy.tar.gz", "--strip-components=1"

    # Apply macOS EGL/ANGLE support patch from akihikodaki
    # This enables proper EGL 1.5 support including eglGetPlatformDisplay
    patch_file = "#{__dir__}/../patches/libepoxy-akihikodaki-egl15.patch"
    ohai "Applying akihikodaki's EGL 1.5 support patch..."
    system "patch", "-p1", "--batch", "--verbose", "-i", patch_file

    # Configure with ANGLE include paths
    angle = Formula["startergo/angle/angle"]
    angle_include = "#{angle.include}"
    angle_pc_path = "#{angle.lib}/pkgconfig"

    system "meson", "setup", "build",
           *std_meson_args,
           "-Dc_args=-I#{angle_include}",
           "--pkg-config-path=#{angle_pc_path}",
           "-Degl=yes",
           "-Dx11=false",
           "-Dtests=false"
    system "meson", "compile", "-C", "build", "--verbose"
    system "meson", "install", "-C", "build"
  end

  def post_install
    # Add rpath to HOMEBREW_PREFIX/lib so dlopen finds ANGLE libraries at runtime
    # ANGLE uses @rpath/libEGL.dylib, and libepoxy dlopen's it
    system "install_name_tool", "-add_rpath", "#{HOMEBREW_PREFIX}/lib", "#{lib}/libepoxy.0.dylib"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <epoxy/gl.h>
      int main() {
        epoxy_glGetString(GL_VERSION);
        return 0;
      }
    EOS

    system ENV.cc, "test.c",
           "-I#{include}",
           "-L#{lib}",
           "-lepoxy",
           "-o", "test"
    system "./test"
  end
end

class Libepoxy < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"
  license "MIT"

  version "1.5.10"
  url "https://github.com/startergo/homebrew-libepoxy/archive/refs/tags/v1.5.10.tar.gz"
  sha256 "3855eaf28271abcce5eb4f4bf7bec5469a5fbe1170c52fb09744e73882b4e7a1"
  head "https://github.com/anholt/libepoxy.git",
       using: :git

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

    # Apply macOS EGL/ANGLE support patch
    patch_file = "#{__dir__}/../patches/libepoxy-changes-main.patch"
    ohai "Applying macOS EGL/ANGLE patch..."
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

class Libepoxy < Formula
  desc "Library for handling OpenGL function pointer management"
  homepage "https://github.com/anholt/libepoxy"

  depends_on "startergo/angle/angle"
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => :build

  version "1.5.10"
  url "https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz"
  sha256 "1d73472585fb44fe8fddc07150dacb60416e050022f58d5aaf7dfae15c1149aa"
  license "MIT"

  head "https://github.com/anholt/libepoxy.git",
       using: :git

  def install
    # Apply macOS EGL/ANGLE support patch
    system "patch", "-p1", "-i", "#{__dir__}/../patches/libepoxy-changes-main.patch"

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

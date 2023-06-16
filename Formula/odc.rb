class Odc < Formula
  desc "Package to read/write ODB data"
  homepage "https://github.com/ecmwf/odc"
  url "https://github.com/ecmwf/odc/archive/refs/tags/1.4.6.tar.gz"
  sha256 "ff99d46175e6032ddd0bdaa3f6a5e2c4729d24b698ba0191a2a4aa418f48867c"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/ecmwf/odc/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ecmwf/homebrew-ecmwf/releases/download/odc-1.4.6"
    sha256 ventura:      "f6134c9243059cedc566b4d7d0f6262a81fb4a8f2e66b2a2d115fa4e75bdf657"
    sha256 x86_64_linux: "a82433834fa7297b69106c37343c1f0b56f51f373e2215de7c80cc223e60228d"
  end

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  depends_on "eckit"
  depends_on "gcc"

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_FORTRAN=ON", *std_cmake_args
      system "cmake", "--build", "."
      system "cmake", "--install", "."
    end

    shim_references = [
      lib/"pkgconfig/odc.pc",
      include/"odc/odc_ecbuild_config.h",
    ]
    inreplace shim_references, Superenv.shims_path/ENV.cxx, ENV.cxx
    inreplace shim_references, Superenv.shims_path/ENV.cc, ENV.cc
  end

  test do
    assert_match "ODBAPI Version: #{version}", shell_output("#{bin}/odc --version")
  end
end

class Ecbuild < Formula
  desc "ECMWF macros for CMake build system"
  homepage "https://github.com/ecmwf/ecbuild"
  url "https://github.com/ecmwf/ecbuild/archive/refs/tags/3.7.2.tar.gz"
  sha256 "7a2d192cef1e53dc5431a688b2e316251b017d25808190faed485903594a3fb9"

  livecheck do
    url "https://github.com/ecmwf/ecbuild/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DENABLE_INSTALL=ON", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "ecbuild version #{version}", shell_output("#{bin}/ecbuild --version | grep ecbuild").strip
  end
end

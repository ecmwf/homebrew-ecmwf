class Ecbuild < Formula
  desc "ECMWF macros for CMake build system"
  homepage "https://github.com/ecmwf/ecbuild"
  url "https://github.com/ecmwf/ecbuild/archive/2.9.0.tar.gz"
  sha256 "91210944e8f71c24bb45b4d58766d2203837036cec0981c51a8dc60943553adb"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", "-DENABLE_INSTALL=ON", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "ecbuild version 2.9.0", shell_output("#{bin}/ecbuild --version | grep ecbuild").strip
  end
end

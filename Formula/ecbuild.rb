class Ecbuild < Formula
  desc "ECMWF macros for CMake build system"
  homepage "https://github.com/ecmwf/ecbuild"
  url "https://github.com/ecmwf/ecbuild/archive/refs/tags/3.7.2.tar.gz"
  sha256 "7a2d192cef1e53dc5431a688b2e316251b017d25808190faed485903594a3fb9"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/ecmwf/ecbuild/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/ecmwf/homebrew-ecmwf/releases/download/ecbuild-3.7.2"
    sha256 cellar: :any_skip_relocation, ventura:      "d8d7e1f8ec422ea245daf63cac022e9d5fff3840c3a55cdefc7de2d81f150ebf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bc6621b466d10840febd80dfa5dd32acf40808200bc54d32a9d27330721038bb"
  end

  depends_on "cmake"

  def install
    mkdir "build" do
      system "cmake", "..", "-DENABLE_INSTALL=ON", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ecbuild --version")

    # create a small sample CMake project that uses ecbuild features
    (testpath/"src/CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
      find_package(ecbuild REQUIRED)
      project(test_ecbuild_install VERSION 0.1.0 LANGUAGES NONE)
      ecbuild_add_option(FEATURE TEST_A DEFAULT OFF)
      if(HAVE_TEST_A)
        message(STATUS "TEST_A ON")
      else()
        message(STATUS "TEST_A OFF")
      endif()
    EOS

    default_output = shell_output("#{bin}/ecbuild -Wno-dev ./src")
    assert_match "TEST_A OFF", default_output
    rm "CMakeCache.txt"

    on_output = shell_output("#{bin}/ecbuild -Wno-dev ./src -DENABLE_TEST_A=ON")
    assert_match "TEST_A ON", on_output
    rm "CMakeCache.txt"

    off_output = shell_output("#{bin}/ecbuild -Wno-dev ./src -DENABLE_TEST_A=OFF")
    assert_match "TEST_A OFF", off_output
  end
end

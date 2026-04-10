class Ecbuild < Formula
  desc "ECMWF macros for CMake build system"
  homepage "https://github.com/ecmwf/ecbuild"
  url "https://github.com/ecmwf/ecbuild/archive/refs/tags/3.13.0.tar.gz"
  sha256 "7be83510e7209c61273121bcf817780597c3afa41a5129bfccc281f0df1ffda1"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/ecmwf/ecbuild/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://get-test.ecmwf.int/repository/homebrew"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "4913edc9a95bca9daf78264b733703e0ec086a1607f776dddced520feea0ea5b"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "26b59b014d44b3e2e9475646e4ed4e9fd86419ea6350f429a1b7188b4f7bba34"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "8bb027f9e4be185140960207a8c5c6984bc500be70094c19449d576e676ae32c"
    sha256 cellar: :any_skip_relocation, tahoe:         "16ed9966e1517974eea54290d154c5719a4a705cd9a10efede2f8de6265b03e4"
    sha256 cellar: :any_skip_relocation, sequoia:       "947ebe5372b7e5076a74b74772810de0d7c97eeacec0db310f62421c217d10db"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "78ac6ebe73fc123b424b423b96be8dcdc27895827c905315428dc8ff1f3222dd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e1c17ee74709509b2e5359ef4e650f7ca08493c37a0ce48bf6e7ac7718539e5e"
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

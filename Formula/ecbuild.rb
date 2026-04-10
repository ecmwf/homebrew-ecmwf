class Ecbuild < Formula
  desc "ECMWF macros for CMake build system"
  homepage "https://github.com/ecmwf/ecbuild"
  url "https://github.com/ecmwf/ecbuild/archive/refs/tags/3.13.1.tar.gz"
  sha256 "9759815aef22c9154589ea025056db086c575af9dac635614b561ab825f9477e"
  license "Apache-2.0"
  revision 1

  livecheck do
    url "https://github.com/ecmwf/ecbuild/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://get-test.ecmwf.int/repository/homebrew"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:   "1acf1e9a4a0be0b64203ac2eaf2430c1d74713d900717e685acb41d6d0272699"
    sha256 cellar: :any_skip_relocation, arm64_sequoia: "c7d45eed7a4808e47f0e004c10cff9ef8bd3302191e3a50ac227278b00913bc3"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:  "55fd0334b2c00de1c360c66c7a294cc66aae14a0103ef1799bd2eb2e313cc02b"
    sha256 cellar: :any_skip_relocation, tahoe:         "46f94f8f113718462a4940350271115662837ac948972ba7a692bdd7200f8fa8"
    sha256 cellar: :any_skip_relocation, sequoia:       "a615ed23d9ec7f8238cb5fea9f12f06e74acae99b9b7dc6d06910562dd37ba6f"
    sha256 cellar: :any_skip_relocation, arm64_linux:   "3002520287b9e03aae7ce4e2a03f822889c8babc588f7438fbd580edcd4a371d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "11d7c8187fe0471d7f7373a5ef555b522c8e36c57edc4e5bc26cd97405bfb7a9"
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

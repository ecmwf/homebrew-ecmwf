class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/archive/refs/tags/1.23.1.tar.gz"
  sha256 "cd3c4b7a3a2de0f4a59f00f7bab3178dd59c0e27900d48eaeb357975e8ce2f15"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/ecmwf/eckit/tags"
    regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  depends_on "cmake" => [:build, :test]
  depends_on "ecbuild" => [:build, :test]
  depends_on "lapack"
  depends_on "lz4"
  depends_on "openblas"
  depends_on "eigen" => :recommended
  uses_from_macos "bzip2"
  uses_from_macos "ncurses"
  uses_from_macos "openssl"

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_MPI=OFF", *std_cmake_args
      system "make", "install"
    end

    shim_references = [
      lib/"pkgconfig/eckit_mpi.pc",
      lib/"pkgconfig/eckit_cmd.pc",
      lib/"pkgconfig/eckit_test_value_custom_params.pc",
      lib/"pkgconfig/eckit_option.pc",
      lib/"pkgconfig/eckit_maths.pc",
      lib/"pkgconfig/eckit_web.pc",
      lib/"pkgconfig/eckit_sql.pc",
      lib/"pkgconfig/eckit.pc",
      lib/"pkgconfig/eckit_linalg.pc",
      lib/"pkgconfig/eckit_geometry.pc",
      include/"eckit/eckit_ecbuild_config.h",
    ]
    inreplace shim_references, Superenv.shims_path/ENV.cxx, ENV.cxx
    inreplace shim_references, Superenv.shims_path/ENV.cc, ENV.cc
  end

  test do
    # write a CMakeLists.txt for building the test
    (testpath/"src/CMakeLists.txt").write <<~EOS
      cmake_minimum_required(VERSION 3.11 FATAL_ERROR)
      find_package(ecbuild REQUIRED)
      project(test_eckit VERSION 0.1.0 LANGUAGES CXX)
      set(CMAKE_CXX_STANDARD 11)
      set(CMAKE_CXX_STANDARD_REQUIRED ON)
      ecbuild_find_package( NAME eckit REQUIRED )
      ecbuild_add_executable(
        TARGET      eckit-test
        SOURCES     test.cc
        LIBS        eckit_maths eckit )
    EOS

    # source code for the test
    (testpath/"src/test.cc").write <<~EOS
      #include <cassert>
      #include <iomanip>
      #include "eckit/testing/Test.h"
      #include "eckit/types/FloatCompare.h"
      #include "eckit/types/Hour.h"
      #include "eckit/maths/Matrix.h"
      #include "eckit/container/DenseMap.h"

      using namespace std;
      using namespace eckit;
      using namespace eckit::testing;

      int main() {

        // test time utilities
        assert(Hour(1.0/60.0) == Hour("0:01"));

        // test containers
        DenseMap<std::string, int> dm;
        dm.insert("two", 2);
        dm.insert("four", 4);
        dm.insert("nine", 9);
        dm.sort();
        assert(dm.get("two") == 2);
        assert(dm.get("nine") == 9);
        assert(dm.get("four") == 4);

        // test matrix functions
        constexpr double tolerance = 1.e-8;
        using eckit::types::is_approximately_equal;
        using Matrix = eckit::maths::Matrix<double>;
        Matrix m{{9., 6., 2., 0., 3.},
                 {3., 6., 8., 10., 12.},
                 {4., 8., 2., 6., 9.},
                 {1., 5., 5., 3., 2.},
                 {1., 3., 6., 8., 10}};
        assert(is_approximately_equal(m.determinant(), 1124., tolerance));
        return 0;
      }
    EOS

    # build using ecbuild to ensure correct compilation flags
    # also set build type to Debug so as to activate assert()
    system "ecbuild", "./src", "-DCMAKE_BUILD_TYPE=Debug"
    system "make"
    system "file", "./bin/eckit-test"
    system "./bin/eckit-test"
  end
end

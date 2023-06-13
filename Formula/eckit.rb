class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/archive/refs/tags/1.23.1.tar.gz"
  sha256 "cd3c4b7a3a2de0f4a59f00f7bab3178dd59c0e27900d48eaeb357975e8ce2f15"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/ecmwf/eckit/tags"
    regex(/^v?(\\d(?:\\.\\d+)+)$/i)
  end

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  depends_on "eigen" => :recommended
  depends_on "armadillo" => :optional
  depends_on "viennacl" => :optional

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
    assert_match version.to_s, shell_output("#{bin}/eckit-version").strip
  end
end

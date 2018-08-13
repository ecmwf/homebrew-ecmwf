class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/archive/0.22.0.tar.gz"
  sha256 "f6bf8f314e771077474242b0105d65a0e91509946c89b5509d2c284ce149fa1c"

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  # depends_on "eigen" => :recommended # currently fails to build -- internactive make works, non-interactive fails
  depends_on "armadillo" => :optional
  depends_on "viennacl" => :optional

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_MPI=OFF", "-DENABLE_EIGEN=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "0.22.0", shell_output("#{bin}/eckit-version").strip
  end
end

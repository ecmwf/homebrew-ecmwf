class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/archive/0.23.0.tar.gz"
  sha256 "4ebc6e8d27f6107db3b18bb50ebf2d78dbc6f11de643c0b7979203b062f451e4"

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
    assert_match "0.23.0", shell_output("#{bin}/eckit-version").strip
  end
end

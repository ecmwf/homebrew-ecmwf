class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/releases/download/0.22.0/eckit-0.22.0-Source.tar.gz"
  sha256 "18cde98d62629a78355c40dfa52d69972c85b409fa482ac4efc4e383ebcd18f0"

  # bottle do
  #   cellar :any
  #   sha256 "397a555e36bdad548c7121c3962d518dc304dc9d033fcf67c4ee4428a460285a" => :high_sierra
  # end

  depends_on "cmake" => :build
  # depends_on "eigen" => :recommended # currently fails to build -- internactive make works, non-interactive fails
  depends_on "armadillo" => :optional
  depends_on "viennacl" => :optional

  def install
    mkdir "build" do
      system "cmake", "..", "-DENABLE_MPI=OFF", "-DENABLE_EIGEN=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "0.22.0", shell_output("#{bin}/eckit-version").strip
  end
end

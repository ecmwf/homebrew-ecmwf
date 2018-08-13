class Eckit < Formula
  desc "ECMWF cross-platform c++ toolkit"
  homepage "https://github.com/ecmwf/eckit"
  url "https://github.com/ecmwf/eckit/releases/download/0.22.0/eckit-0.22.0-Source.tar.gz"
  sha256 "18cde98d62629a78355c40dfa52d69972c85b409fa482ac4efc4e383ebcd18f0"

  # bottle do
  #   sha256 "f7e078f54c455461daf8fc9380f464eef78fd47349304312c5705a21f5136fef" => :high_sierra
  #   sha256 "6f52dde3cc19cf888118734f53d568fccb0fa6c6e5e71fff60974ebc4a667e5b" => :sierra
  #   sha256 "0eae38514c8ebed471f33c6d8824d2272ebf41ebd76092d35d9938fbacbca61c" => :el_capitan
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

class Atlas < Formula
  desc "ECMWF library for parallel data-structures supporting unstructured grids and function spaces"
  homepage "https://github.com/ecmwf/atlas"
  url "https://github.com/ecmwf/atlas/archive/0.15.1.tar.gz"
  sha256 "24fea5e06072a77974947ca6062e61a6fa127f8aab9cc1a9b51beae0c4ab5ee0"

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  depends_on "eckit"

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_FORTRAN=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "0.15.1", shell_output("#{bin}/atlas --version").strip
  end
end

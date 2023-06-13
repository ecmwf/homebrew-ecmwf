class Atlas < Formula
  desc "ECMWF library for parallel data-structures supporting unstructured grids and function spaces"
  homepage "https://github.com/ecmwf/atlas"
  url "https://github.com/ecmwf/atlas/archive/0.15.2.tar.gz"
  sha256 "8c53843be4a14111497e154087810a2a0c4a0d9941c1e3d4dd2e9189f21f4f95"

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  depends_on "eckit"
  # depends_on "eigen" => :recommended # currently fails to build -- internactive make works, non-interactive fails

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_FORTRAN=OFF", "-DENABLE_EIGEN=OFF", *std_cmake_args
      system "make", "install"
    end
  end

  test do
    assert_match "0.15.2", shell_output("#{bin}/atlas --version").strip
  end
end

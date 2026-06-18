class Atlas < Formula
  desc "ECMWF library for numerical weather prediction and climate modelling"
  homepage "https://github.com/ecmwf/atlas"
  url "https://github.com/ecmwf/atlas/archive/refs/tags/0.34.0.tar.gz"
  sha256 "48536742cec0bc268695240843ac0e232e2b5142d06b19365688d9ea44dbd9ba"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/ecmwf/homebrew-ecmwf/releases/download/atlas-0.33.0"
    rebuild 1
    sha256 cellar: :any, ventura: "5c4866d6bd82c04168c404709452822a0c3aa842b3acc522586ec43fb4989001"
  end

  depends_on "cmake" => :build
  depends_on "ecbuild" => :build
  depends_on "eckit"
  depends_on "eigen" => :recommended # currently fails to build -- internactive make works, non-interactive fails

  def install
    mkdir "build" do
      system "ecbuild", "..", "-DENABLE_FORTRAN=OFF", *std_cmake_args
      system "make", "install"
    end

    shim_references = [
      lib/"pkgconfig/atlas.pc",
      lib/"pkgconfig/atlas-c++.pc",
      include/"atlas/atlas_ecbuild_config.h",
    ]
    inreplace shim_references, Superenv.shims_path/ENV.cxx, ENV.cxx
    inreplace shim_references, Superenv.shims_path/ENV.cc, ENV.cc
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/atlas --version")
  end
end

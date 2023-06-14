class Atlas < Formula
  desc "ECMWF library for numerical weather prediction and climate modelling"
  homepage "https://github.com/ecmwf/atlas"
  url "https://github.com/ecmwf/atlas/archive/refs/tags/0.33.0.tar.gz"
  sha256 "a91fffe9cecb51c6ee8549cbc20f8279e7b1f67dd90448e6c04c1889281b0600"

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
    assert_match version.to_s, shell_output("#{bin}/atlas --version").strip
  end
end

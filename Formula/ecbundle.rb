class Ecbundle < Formula
  include Language::Python::Virtualenv

  desc "Bundle management tool for CMake projects"
  homepage "https://github.com/ecmwf/ecbundle"
  url "https://github.com/ecmwf/ecbundle/archive/refs/tags/2.4.0.tar.gz"
  sha256 "542da932b6884383690b3ea144e3ec0f88f466364bec0422be11e6ea2faf457b"
  license "Apache-2.0"

  livecheck do
      url "https://github.com/ecmwf/ecbundle/tags"
      regex(/^v?(\d(?:\.\d+)+)$/i)
  end

  depends_on "python@3.13"

  resource "ruamel-yaml" do
      url "https://files.pythonhosted.org/packages/c7/3b/ebda527b56beb90cb7652cb1c7e4f91f48649fbcd8d2eb2fb6e77cd3329b/ruamel_yaml-0.19.1.tar.gz"
      sha256 "53eb66cd27849eff968ebf8f0bf61f46cdac2da1d1f3576dd4ccee9b25c31993"
  end

  resource "ruamel-yaml-clib" do
      url "https://files.pythonhosted.org/packages/ea/97/60fda20e2fb54b83a61ae14648b0817c8f5d84a3821e40bfbdae1437026a/ruamel_yaml_clib-0.2.15.tar.gz"
      sha256 "46e4cc8c43ef6a94885f72512094e482114a8a706d3c555a34ed4b0d20200600"
  end

  def install
      virtualenv_install_with_resources
  end

  test do
      assert_match version.to_s, shell_output("#{bin}/ecbundle --version")
  end
end

require_relative "../lib/github_private_download_strategy"

class EcmwfToolbox < Formula
  desc "ECMWF software bundle: ecCodes, Magics, Metview, Atlas, and more"
  homepage "https://github.com/ecmwf/ecmwf-toolbox"
  url "https://github.com/ecmwf/ecmwf-toolbox.git",
      tag:       "2026.01.0.0",
      using:     GitHubPrivateDownloadStrategy,
      token_env: "HOMEBREW_GH_REPO_READ_TOKEN"
  license "Apache-2.0"

  depends_on "cmake" => :build
  depends_on "ecbundle" => :build
  depends_on "pkg-config" => :build
  depends_on "cairo"
  depends_on "curl"
  depends_on "eigen"
  depends_on "expat"
  depends_on "fftw"
  depends_on "gcc"
  depends_on "glib"
  depends_on "jasper"
  depends_on "libaec"
  depends_on "libomp"
  depends_on "libpng"
  depends_on "libzip"
  depends_on "lz4"
  depends_on "netcdf"
  depends_on "open-mpi"
  depends_on "openjpeg"
  depends_on "pango"
  depends_on "proj"
  depends_on "python@3.13"
  depends_on "qhull"
  depends_on "snappy"
  uses_from_macos "bzip2"
  uses_from_macos "ncurses"
  on_linux do
    depends_on "util-linux"
  end

  def install
    ENV.append("GIT_TERMINAL_PROMPT", "0")
    ENV.append("BITBUCKET", "https://git.ecmwf.int")

    # Write git credentials so ecbundle can clone private repos
    gh_token = ENV["HOMEBREW_GH_REPO_READ_TOKEN"]
    bb_token = ENV["HOMEBREW_BITBUCKET_PAT"]
    secrets = [gh_token, bb_token].compact.reject(&:empty?)

    creds = []
    creds << "https://x-access-token:#{gh_token}@github.com" if gh_token
    creds << "https://x-token-auth:#{bb_token}@git.ecmwf.int" if bb_token

    unless creds.empty?
      (Pathname.new(Dir.home) / ".git-credentials").write(creds.join("\n") + "\n")
      system "git", "config", "--global", "credential.helper", "store"
    end

    # On Linux, Homebrew uses clang which needs explicit OpenMP include/lib paths
    unless OS.mac?
      ENV.append "CPPFLAGS", "-I#{Formula["libomp"].opt_include}"
      ENV.append "LDFLAGS", "-L#{Formula["libomp"].opt_lib}"
    end

    # On Linux, shadow system clang-tidy with a no-op script. Atlas
    # auto-enables clang-tidy when found, and the system clang can't
    # find omp.h from GCC's internal include paths.
    unless OS.mac?
      (buildpath/"bin/clang-tidy").write "#!/bin/sh\nexit 0\n"
      chmod 0755, buildpath/"bin/clang-tidy"
      ENV.prepend_path "PATH", buildpath/"bin"
    end

    # In CI, capture build output to a log file for upload to Nexus.
    # HOMEBREW_ECMWF_BUILD_LOG must point to a sandbox-writable path (e.g. /tmp).
    # Locally, stream sanitized output to stdout.
    ci = ENV["CI"]
    build_log_path = ENV["HOMEBREW_ECMWF_BUILD_LOG"]

    run_build = lambda do |output_io|
      # ecbundle create: downloads all git repos + generates CMakeLists.txt
      run_ecbundle(secrets, output_io, "ecbundle", "create", "--bundle", buildpath.to_s)

      # ecbundle build: cmake configure + compile + install
      run_ecbundle(secrets, output_io,
                    "ecbundle", "build",
                    "--src-dir", "source",
                    "--build-dir", "build",
                    "--install-dir", prefix.to_s,
                    "--build-type", "Release",
                    "--without-tests",
                    "--cmake", "ENABLE_AEC=ON",
                    "--cmake", "ENABLE_FFTW=ON",
                    "--cmake", "ENABLE_NETCDF=ON",
                    "--cmake", "ENABLE_PROJ=ON",
                    "--cmake", "ENABLE_PNG=ON",
                    "--cmake", "ENABLE_FDB5=ON",
                    "--cmake", "ENABLE_CLANG_TIDY=OFF",
                    "--cmake", "INSTALL_LIB_DIR=lib",
                    "--cmake", "CMAKE_PREFIX_PATH=#{ENV["CMAKE_PREFIX_PATH"]}",
                    "--cmake", "OpenMP_ROOT=#{Formula["libomp"].opt_prefix}",
                    "--install",
                    "-j#{ENV.make_jobs}")
    end

    if ci && build_log_path
      File.open(build_log_path, "w") { |f| run_build.call(f) }
    elsif ci
      File.open(File::NULL, "w") { |f| run_build.call(f) }
    else
      run_build.call($stdout)
    end

    # Fix shim references in pkg-config files and ecbuild config headers
    files_to_fix = Dir[lib/"pkgconfig/*.pc", include/"**/*_ecbuild_config.h"]

    inreplace files_to_fix do |s|
      s.gsub! "#{Superenv.shims_path}/", ""
    end

    # Remove build log that contains shim references
    rm pkgshare/"build.log"
  end

  test do
    system bin/"codes_info"
  end

  private

  def run_ecbundle(secrets, output_io, *cmd)
    require "open3"
    Open3.popen2e(*cmd) do |_stdin, out_err, wait_thr|
      out_err.each_line do |line|
        secrets.each { |s| line.gsub!(s, "[REDACTED]") }
        output_io.print line
      end
      status = wait_thr.value
      raise "#{cmd.first} failed with exit code #{status.exitstatus}" unless status.success?
    end
  end
end

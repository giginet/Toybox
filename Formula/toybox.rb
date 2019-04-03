class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.1.tar.gz"
  sha256 "848bb5db02a25af24869c77b54efd49003a4c42f68d47a8bd3821fb7c8f4bdb8"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/1.0.1"
    sha256 "b986ec91fccf08d2eec947472c2f2a703cb9f54c51cad5c529edbf87409bf572" => :high_sierra
  end

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "shell-completions/toybox-bash-completion" => "toybox"
    zsh_completion.install "shell-completions/toybox-zsh-completion" => "_toybox"
  end

  test do
    system bin/"toybox"
  end
end

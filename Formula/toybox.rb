class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.0.0.tar.gz"
  sha256 "395408a3dc9c3db2b5c200b8722a13a60898c861633b99e6e250186adffd1370"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/1.0.1"
    sha256 "395408a3dc9c3db2b5c200b8722a13a60898c861633b99e6e250186adffd1370" => :high_sierra
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

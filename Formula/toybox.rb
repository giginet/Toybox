class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.0.0.tar.gz"
  sha256 "946ecf32206ee40a0d1fc8846f440019cce157709c22586642a8ad6b08602a01"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/2.0.0"
    sha256 "946ecf32206ee40a0d1fc8846f440019cce157709c22586642a8ad6b08602a01" => :high_sierra
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

class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.0.0.tar.gz"
  sha256 " a2fa8907aacb8924ea672eb20eda5fff5c23f8b58eb75e90fd20774a0d4e0bac"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode => ["10.2", :build]


  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/2.1.0"
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

class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.0.0.tar.gz"
  sha256 "08ae74f3a4561b5ac6077ced9a613fac1a46c026b06f554599795d1940d96f55"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode => ["10.2", :build]

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/2.0.0"
    sha256 "08ae74f3a4561b5ac6077ced9a613fac1a46c026b06f554599795d1940d96f55" => :high_sierra
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

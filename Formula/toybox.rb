class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.0.0.tar.gz"
  sha256 "64c6e7ec4c3d648a76a50ceae3dfcbc3e9860e044c58000bab485bb9eb5fadef"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode => ["10.2", :build]


  bottle do
    cellar :any_skip_relocation
    sha256 "555db9f89edad2ed8ce1e60a145f00cb2dd389145f9b4e25926be59a94976c3b" => :mojave
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

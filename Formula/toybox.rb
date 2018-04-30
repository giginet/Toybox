class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.1.tar.gz"
  sha256 "315446308e40c33aa46fca1b2558d14e005d6e91505c50d4dc67cf87d38d7ee1"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode
  depends_on 'carthage' => :build

  def install
    system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Sources/Scripts/toybox-bash-completion" => "toybox"
    zsh_completion.install "Sources/Scripts/toybox-zsh-completion" => "_toybox"
  end

  test do
    system bin/"toybox"
  end
end

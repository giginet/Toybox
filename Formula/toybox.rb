class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.1.tar.gz"
  sha256 "6ad5a80f06ae05e269fc581504a2ca539a93f0ebc207eafa21c1569c5f6e9390"
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

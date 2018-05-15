class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.1.tar.gz"
  sha256 "848bb5db02a25af24869c77b54efd49003a4c42f68d47a8bd3821fb7c8f4bdb8"
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

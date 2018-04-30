class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.1.tar.gz"
  sha256 "aff47dd3932978bec6e271e1a4b9515b3223a24ca6926252004ee47c1f0dcbc1"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode
  depends_on 'carthage' => :build

  def install
    # system "make", "prefix_install", "PREFIX=#{prefix}"
    bash_completion.install "Sources/Scripts/toybox-bash-completion" => "toybox"
    zsh_completion.install "Sources/Scripts/toybox-zsh-completion" => "_toybox"
  end

  test do
    system bin/"toybox"
  end
end

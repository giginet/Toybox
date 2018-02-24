class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/1.0.0.tar.gz"
  sha256 "bcc9599a336a0043fb4eb0a48d2318b3db64ff111c7de8736d40b9deca3f37fa"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode
  depends_on 'carthage' => :build

  def install
    system "make", "prefix_install", "PREFIX=#{HOMEBREW_PREFIX}"
    bash_completion.install "Sources/Scripts/toybox-bash-completion" => "toybox"
    zsh_completion.install "Sources/Scripts/toybox-zsh-completion" => "_toybox"
  end

  test do
    system bin/"toybox"
  end
end

class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox.git",
      :tag => "1.0.0",
      :revision => "a020c486436870bcf58b376b661cad4c7b2998d2",
      :shallow => false
  head "https://github.com/giginet/Toybox.git", :shallow => false
 
  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/1.0.0"
    sha256 "bcc9599a336a0043fb4eb0a48d2318b3db64ff111c7de8736d40b9deca3f37fa" => :sierra
  end

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

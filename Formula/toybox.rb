class Toybox < Formula
  desc "Xcode Playground management made easy"
  homepage "https://github.com/giginet/Toybox"
  url "https://github.com/giginet/Toybox/archive/2.1.0.tar.gz"
  sha256 "5f6b9dd329e3d4ce9e3f3260f32a43eef4dc9e625413b20c17e56835a296a77b"
  head "https://github.com/giginet/Toybox.git"

  depends_on :xcode => ["10.2", :build]

  bottle do
    cellar :any_skip_relocation
    root_url "https://github.com/giginet/Toybox/releases/download/2.1.0"
    sha256 "c3cf3859312ee0c4212d2705f35f0307b20a87ed0222b86cd7fb578aec22958a" => :mojave
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

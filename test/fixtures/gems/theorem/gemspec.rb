gemspec "mruby-bin-theorem" do |config|
  task "say hello" do
    def build
      command("echo 'theorem hello world'")
      command("echo 'foo' > foo.txt")
    end
  end

  gem path: "../thread"
end
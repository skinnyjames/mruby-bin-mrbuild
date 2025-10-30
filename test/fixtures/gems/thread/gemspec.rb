gemspec "mruby-thread" do |config|
  task "yow" do |yow|
    def build
      command("echo 'yawowoowowow' > yaow.txt")
    end
  end
end
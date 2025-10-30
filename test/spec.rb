class SpecTest
  include Theorem::Hypothesis

  let(:top) do
    spec("mruby-bin-top") do |config|
      config.author = "skinnyjames"

      task "one" do |args|
        def build
          command("ls #{args[:dir]}")
        end
      end

      task "two" do |args|
        def build
          command("git status")
        end
      end

      task "three" do |three|
        dependency "one"
        dependency "two" do
          files "hello.world"
        end

        def build
          command("pwd")
          command("ls", chdir: "test")
        end
      end

      gem path: "test/fixtures/gems/theorem"
    end
  end

  test "gemspec thing" do
    puts top.execute('one:dir="lib" two:command=3')
  end
end
class GemSpecTest
  include Theorem::Hypothesis

  let(:top) do
    gemspec("mruby-bin-top") do |config|
      config.author = "skinnyjames"

      task "one", path: "." do |one|
        def build
          command("ls", chdir: "test/fixtures")
        end
      end

      task "two", path: "." do |two|
        def build
          command("git status")

        end
      end

      task "three", path: "." do |three|
        dependency "one"
        dependency "two"

        def build
          command("pwd")
          command("ls", chdir: "test")
        end
      end

      gem path: "test/fixtures/gems/theorem"
    end
  end

  test "gemspec thing" do
    puts top.execute
  end
end
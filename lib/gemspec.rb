
module MRBuild
  class GemSpec
    class ::String
      # colorization
      def colorize(color_code)
        "\e[#{color_code}m#{self}\e[0m"
      end

      def red
        colorize(31)
      end

      def green
        colorize(32)
      end

      def yellow
        colorize(33)
      end

      def blue
        colorize(34)
      end

      def pink
        colorize(35)
      end

      def light_blue
        colorize(36)
      end
    end

    class CConfig
      attr_accessor :gcc, :ar, :libs, :objs, :includes,
                    :defines, :linker_flags, :linker_library_paths,
                    :flags, :mrbfiles

      def initialize
        @gcc = "gcc"
        @ar = "ar"
        @libs = []
        @objs = []
        @includes = []
        @defines = []
        @linker_flags = []
        @linker_library_paths = []
        @flags = []
        @mrbfiles = []
      end

      def gcc
        "#{@gcc} #{@defines.map{ |d| "-D#{d}" }.join(" ")}"
      end
    end

    class Config
      attr_accessor :version, :author, :gems, :cc, :bins

      def initialize
        @version = nil
        @author = nil
        @gems = {}
        @cc = CConfig.new
      end
    end

    attr_reader :name, :registry, :gems, :tasks, :config, :root, :path

    def initialize(name, config, path = ".", registry = MRBuild::Registry.new)
      @name = name
      @registry = registry
      @tasks = []
      @gems = []
      @config = config
      @path = path
      @root = MRBuild::Task.new("#{name}-task-root")
    end

    # @return [nil]
    def execute()
      fibers = gemspecs.map do |gemspec|
        Fiber.new do
          gemspec.execute
        end
      end
      
      colors = [:yellow, :blue, :pink, :light_blue]
      registry.tasks.each do |task|
        color = colors.shift
        task.on_output do |output|
          puts "#{name}::#{task.name} - #{output}".send(color)
          colors << color
        end
      end

      orchestrator = MRBuild::Orchestrator.new(registry, workers: 2)

      orchestrator.on_run_start do
        puts "#{name} run started"
      end

      orchestrator.on_task_start do |task|
        puts "#{name}::#{task} started"
      end

      orchestrator.on_task_failed do |task, ex|
        puts "#{name}::#{task} failed #{ex}".red
      end

      orchestrator.on_task_succeed do |task|
        puts "#{name}::#{task} did the damn thing".green
        Fiber.yield
      end

      orchestrator.on_run_finished do
        puts "#{name} run finished"
      end

      # orchestrator.on_unblocked do |unblock|
      #   puts unblock.to_s
      # end

      fibers << Fiber.new do
        orchestrator.execute
      end

      while fiber = fibers.shift 
        if fiber.alive?
          fiber.resume
          fibers << fiber
        end
      end
    end

    def task(name, **args, &block)
      task = MRBuild::Task.new(name, path, **args, &block)
      root.dependency task.name
      task.load
      registry << task
    end

    def gem(name = nil, **args, &block)
      args[:path] = File.join(path, args[:path]) if args[:path]
      gems << Gem.new(config, **args, &block)
    end

    def gemspec(name, &block)
      conf = MRBuild::GemSpec::Config.new
      conf.cc = config.cc
      conf.gems = config.gems

      # location is dynamically set from task.rb
      spec = MRBuild::GemSpec.new(name, conf, location)
      spec.instance_exec(spec, config) do |obj, config|
        if !block.parameters.empty? && block.parameters.first.last
          Object.define_method(block.parameters.first.last) do
            config
          end
        end

        obj.instance_exec(config, &block)
        obj
      end

      spec
    end

    def gemspecs
      @gemspecs ||= begin
        stack = gems.dup
        specs = []

        while gem = stack.shift
          next if config.gems[gem.id]

          spec = gem.resolve(self)
          next if config.gems[spec.name]

          specs.unshift spec

          config.gems[gem.id] = true
          config.gems[spec.name] = spec

          stack.concat spec.gems
        end

        specs
      end
    end
  end
end

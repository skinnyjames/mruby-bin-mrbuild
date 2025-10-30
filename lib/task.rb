require_relative "./commands"
require_relative "./resolver"

module MRBuild
  class Dependency
    attr_reader :name, :resolver, :override
    
    def initialize(name)
      @name = name
    end
  end

  class Gem
    attr_reader :resolver, :override

    def initialize(config, **args, &override)
      @config = config
      @resolver = Resolver.locate(**args)
      @override = override
    end

    def resolve(parent)
      resolver.resolve

      file = File.read(File.join(resolver.path, "gemspec.rb"))
      spec = parent.instance_exec(resolver) do |res|
        Object.define_method(:location) do
          res.path
        end

        instance_eval(file)
      end

      spec
    end

    def id
      resolver.id
    end
  end

  class Task
    include Commands

    attr_reader :name, :resolver, :block, :dependencies, :path

    def initialize(name, path = ".", **args, &block)
      @name = name
      @path = path
      @resolver = Resolver.locate(**args)
      @block = block
      @dependencies = []
      @commands = []
    end

    def include(mod)
      self.class.include(mod)
    end

    def dependency(name, **args)      
      self.dependencies << Dependency.new(name, **args)
    end

    def execute
      build
  
      @commands.each(&:execute)
    end

    def load
      # resolver.resolve!
      unless block.nil?
        instance_exec(self, resolver) do |obj, resolver|
          Object.define_method(block.parameters.first.last) do
            resolver
          end

          obj.instance_exec(resolver, &block)
        end
      end
    end
  end
end

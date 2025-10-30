module Barista
  class Registry
    attr_reader :tasks, :inverted

    def initialize(tasks = [])
      @tasks = tasks
      @inverted = false
    end

    def <<(task)
      tasks << task if self[task.name].nil?
    end

    def invert
      @inverted = true
      
      self
    end

    def dag(lock = {})
      graph = Graph.new
      
      tasks.dup.each do |task|
        graph.add(task.name)

        task.dependencies.each do |dependency|
          next unless dependency.active(lock[task.name] || {})

          if inverted
            graph.add_edge(task.name, dependency.name)
          else
            graph.add_edge(dependency.name, task.name)
          end
        end
      end

      graph
    end

    def [](name)
      to_groups[name]
    end

    def reset
      @tasks = []
      @inverted = false

      self
    end

    def upstreams(task)
      lookup = to_groups
      filtered = dag.filter([task.name])
      (filtered - [task.name]).sort.map do |name|
        lookup[name]
      end
    end

    private 

    def to_groups
      tasks.reduce({}) do |memo, task|
        memo[task.name] = task
        memo
      end
    end
  end
end

require_relative "./emittable"
require_relative "./commands/base"
require_relative "./commands/command"
require_relative "./graph"
require_relative "./task"
require_relative "./registry"
require_relative "./orchestrator"
require_relative "./gemspec"

module MRBuild
  class Error < StandardError; end
end


def gemspec(name, config = MRBuild::GemSpec::Config.new, gems = [], &block)
  spec = MRBuild::GemSpec.new(name, config)
  spec.instance_exec(spec, config) do |obj, config|
    if !block.parameters.empty? && block.parameters.first.last
      Object.define_method(block.parameters.first.last) do
        config
      end
    end

    obj.instance_exec(config, &block)
  end

  spec
end

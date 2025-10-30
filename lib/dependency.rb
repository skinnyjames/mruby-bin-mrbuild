module Barista
  class Dependency
    attr_reader :name, :block

    def initialize(name, &block)
      @name = name
      @block = block.nil? ? Proc.new {} : block
      @files = {}
    end

    def files(*list)
      list.each do |file|
        @files[file] = File.exist?(file) ? File.mtime(file) : nil
      end
    end

    # the dependency is active if
    # the dependent files do not exist and
    # the dependent files are newer or on par with the locked version of those files
    def active(locked = {})
      instance_eval(&block)

      @files.reduce(true) do |memo, (file, time)|
        memo && (!time || locked[file].nil? || time >= locked[file])
      end
    end 
  end
end
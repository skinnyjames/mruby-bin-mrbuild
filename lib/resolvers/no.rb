module MRBuild
  class NoResolver
    def location
      Dir.pwd
    end

    def resolve!

    end
  end
end
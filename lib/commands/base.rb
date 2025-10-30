module MRBuild
  module Commands
    class Base
      include Emittable

      def execute
        raise MRBuild::Error.new("#{self.class}#execute must be implemented")
      end

      def description
        raise MRBuild::Error.new("#{self.class}#description must be implemented")
      end
    end
  end
end

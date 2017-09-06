module Whaletamer
  module Dockerfile
    def self.generate(image_config)
      Generator.new(image_config).generate
    end

    class Generator
      attr_reader :config

      def initialize(image_config)
        @config = image_config
      end

      def generate
        dockerfile = config["dockerfile"]
        dockerfile_root = File.dirname(dockerfile)

        DSL.new.evaluate(File.read(dockerfile))
      end
    end

    class DSL
      attr_reader :buffer

      def initialize
        @buffer = []
      end

      def evaluate(dsl)
        instance_eval(dsl)
        buffer.join("\n")
      end

      def from(image)
        buffer << "FROM #{image}"
      end

      def run(command)
        buffer << "RUN #{command}"
      end
    end
  end
end

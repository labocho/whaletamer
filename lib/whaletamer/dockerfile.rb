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

        DSL.new(config["attributes"]).evaluate(File.read(dockerfile))
      end
    end

    class DSL
      attr_reader :buffer, :attributes
      private :buffer

      def initialize(attributes)
        @buffer = []
        @attributes = attributes
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

      def copy(src_and_dest)
        buffer << "COPY #{src_and_dest}"
      end
    end
  end
end

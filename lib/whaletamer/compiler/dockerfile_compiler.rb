module Whaletamer
  class Compiler
  module DockerfileCompiler
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

        %w(FROM RUN CMD LABEL MAINTAINER EXPOSE ENV ADD COPY ENTRYPOINT VOLUME USER WORKDIR ARG ONBUILD STOPSIGNAL HEALTHCHECK SHELL).each do |directive|
          define_method(directive.downcase) do |arg|
            buffer << "#{directive} #{arg}"
          end
        end
      end
    end
  end
end

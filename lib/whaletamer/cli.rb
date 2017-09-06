require "thor"

module Whaletamer
  class CLI < Thor
    desc "init", "Generate boilerplate"
    def init
      # TODO
    end

    desc "dockerfile IMAGE_NAME", "Dockerfile and print"
    def dockerfile(image_name)
      dockerfile = Dockerfile.generate(load_image_config(image))
      puts dockerfile
    end

    desc "build IMAGE_NAME", "Build docker image"
    def build(image_name)
      require "tmpdir"
      dockerfile = Dockerfile.generate(load_image_config(image_name))
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          File.write("Dockerfile", dockerfile)
          unless system("docker", "build", "--tag=#{image_name}", ".", out: $stdout, err: $stderr)
            exit $?
          end
        end
      end
    end

    private
    def load_image_config(image_name)
      config = Config.load
      config.fetch(image_name)
    end
  end
end

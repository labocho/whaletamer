require "thor"

module Whaletamer
  class CLI < Thor
    desc "init", "Generate boilerplate"
    def init
      # TODO

      puts "Generate encryption_key..."
      system("openssl rand -base64 512 | tr -d '\\r\\n' > encryption_key")

      system("echo /encryption_key >> .gitignore")
    end

    desc "dockerfile IMAGE_NAME", "Dockerfile and print"
    def dockerfile(image_name)
      dockerfile = Dockerfile.generate(load_image_config(image_name))
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

    desc "encrypt", "Encrypt STDIN"
    def encrypt
      print Config.encrypt($stdin.read)
    end

    desc "decrypt", "Decrypt STDIN"
    def decrypt
      print Config.decrypt($stdin.read)
    end

    private
    def load_image_config(image_name)
      config = Config.load
      config.fetch(image_name)
    end
  end
end

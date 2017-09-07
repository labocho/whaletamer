require "thor"

module Whaletamer
  class CLI < Thor
    desc "init", "Generate boilerplate"
    def init
      # TODO

      puts "Generate encryption_key..."
      system("openssl rand -base64 512 | tr -d '\\r\\n' > encryption_key")

      system("echo /encryption_key >> .gitignore")
      system("echo /.compiled >> .gitignore")

      # generate config.yml
    end

    desc "dockerfile IMAGE_NAME", "Dockerfile and print"
    def dockerfile(image_name)
      compiler = Compiler.new
      dockerfile = compiler.compile_dockerfile(image_name)
      puts dockerfile
    end

    desc "compile IMAGE_NAME", "Compile Dockerfile and files to .compiled/IMAGE_NAME"
    def compile(image_name)
      dir = ".compiled/#{image_name}"
      FileUtils.rm_rf(dir)
      FileUtils.mkdir_p(dir)

      compiler = Compiler.new
      compiler.compile(image_name, dir)
    end

    desc "build IMAGE_NAME", "Build docker image"
    def build(image_name)
      require "tmpdir"

      Dir.mktmpdir do |dir|
        compiler = Compiler.new
        compiler.compile(image_name, dir)

        Dir.chdir(dir) do
          unless system("docker", "build", "--tag=#{image_name}", ".", out: $stdout, err: $stderr)
            exit $?
          end
        end
      end
    end

    desc "encrypt", "Encrypt STDIN"
    def encrypt
      print Compiler.new.encrypter.encrypt($stdin.read)
    end

    desc "decrypt", "Decrypt STDIN"
    def decrypt
      print Compiler.new.encrypter.decrypt($stdin.read)
    end
  end
end

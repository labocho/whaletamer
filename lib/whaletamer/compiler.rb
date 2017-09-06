require "yaml"
require "fileutils"
require "pathname"

module Whaletamer
  class Compiler
    require "whaletamer/compiler/encryption"

    include Encryption

    attr_reader :config

    def initialize
      @config = load_config
    end

    def compile(image_name, dest_dir)
      image_root = "dockerfile/#{image_name}"

      File.write(File.join(dest_dir, "Dockerfile"), compile_dockerfile(image_name))
      compile_files(image_root, dest_dir)
    end

    def compile_dockerfile(image_name)
      Dockerfile.generate(config.fetch(image_name))
    end

    private
    def load_config
      decrypt_object(YAML.load_file("config.yml"))
    end

    def compile_files(image_root, dest_dir)
      files_root = File.join(image_root, "files")

      Dir.glob("#{files_root}/**/*", File::FNM_DOTMATCH).each do |src|
        next unless File.file?(src)
        relative_path = Pathname.new(src).relative_path_from(Pathname.new(files_root))
        dest = File.join(dest_dir, relative_path)
        FileUtils.mkdir_p(File.dirname(dest))
        if src =~ /\.encrypted$/
          dest.gsub!(/\.encrypted$/, "")
          File.write(dest, decrypt(File.read(src)))
        else
          FileUtils.cp(src, dest)
        end
      end
    end
  end
end

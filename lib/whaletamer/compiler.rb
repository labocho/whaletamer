require "yaml"
require "fileutils"
require "pathname"
require "erb"

module Whaletamer
  class Compiler
    require "whaletamer/compiler/encrypter"
    require "whaletamer/compiler/image_compiler"

    attr_reader :config, :encrypter

    def initialize
      @encrypter = Encrypter.new
      @config = load_config
    end

    def compile(image_name, dest_dir)
      build_image_compiler(image_name).compile(dest_dir)
    end

    def compile_dockerfile(image_name)
      build_image_compiler(image_name).compile_dockerfile
    end

    private
    def load_config
      encrypter.decrypt_object(YAML.load_file("config.yml"))
    end

    def build_image_compiler(image_name)
      ImageCompiler.new("dockerfile/#{image_name}", config.fetch(image_name), encrypter)
    end
  end
end

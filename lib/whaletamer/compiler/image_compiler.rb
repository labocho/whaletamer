require "fileutils"
require "pathname"

module Whaletamer
  class Compiler
    class ImageCompiler
      attr_reader :src_dir, :config, :encrypter

      def initialize(src_dir, config, encrypter)
        @src_dir = src_dir
        @config = config
        @encrypter = encrypter
      end

      def compile(dest_dir)
        File.write(File.join(dest_dir, "Dockerfile"), compile_dockerfile)
        compile_files(dest_dir)
        compile_templates(dest_dir, config["attributes"] || {})
      end

      def compile_dockerfile
        DockerfileCompiler.generate(config)
      end

      private
      def compile_files(dest_dir)
        files_root = File.join(src_dir, "files")

        Dir.glob("#{files_root}/**/*", File::FNM_DOTMATCH).each do |src|
          next unless File.file?(src)
          relative_path = Pathname.new(src).relative_path_from(Pathname.new(files_root))
          dest = File.join(dest_dir, relative_path)
          FileUtils.mkdir_p(File.dirname(dest))

          if src =~ /\.encrypted$/
            dest.gsub!(/\.encrypted$/, "")
            File.write(dest, encrypter.decrypt(File.read(src)))
          else
            FileUtils.cp(src, dest)
          end
        end
      end

      def compile_templates(dest_dir, attributes)
        templates_root = File.join(src_dir, "templates")

        Dir.glob("#{templates_root}/**/*", File::FNM_DOTMATCH).each do |src|
          next unless File.file?(src)
          relative_path = Pathname.new(src).relative_path_from(Pathname.new(templates_root))
          dest = File.join(dest_dir, relative_path)
          FileUtils.mkdir_p(File.dirname(dest))

          File.write(dest, compile_template(src, attributes))
        end
      end

      def compile_template(src, attributes)
        b = binding
        b.local_variable_set(:attributes, attributes)
        ERB.new(File.read(src), nil, "-").result(b)
      end
    end
  end
end

require "yaml"

module Whaletamer
  module Config
    def self.load
      YAML.load_file("images.yml")
    end
  end
end

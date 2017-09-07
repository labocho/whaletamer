require "shellwords"
module Whaletamer
  module Helper
    def user(name, **options)
      command = ["useradd", "-m"]
      if options[:shell]
        command += ["-s", options[:shell]]
      end
      command << name

      run command.shelljoin
    end
  end
end

require "shellwords"
module Whaletamer
  module Helper
    def user(name, shell: nil, uid: nil)
      command = ["useradd", "-m"]
      command += ["-s", shell] if shell
      command += ["-u", uid] if uid
      command << name

      run command.shelljoin
    end

    def directory(name, owner: nil, group: nil, mode: nil)
      commands = [["mkdir", name]]
      commands << ["chown", "#{owner}:#{group}", name] if owner || group
      commands << ["chmod", mode, name] if mode

      run commands.map(&:shelljoin).join(" && ")
    end

    def file(dest, owner: nil, group: nil, mode: nil)
      src = dest.gsub(/^\//, "")
      copy [src, dest].shelljoin

      commands = []
      commands << ["chown", "#{owner}:#{group}", dest] if owner || group
      commands << ["chmod", mode, dest] if mode

      run commands.map(&:shelljoin).join(" && ") if commands.any?
    end
  end
end

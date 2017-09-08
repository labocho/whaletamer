from "centos:7"
run "yum install -y git"
run "yum install -y gcc-6 bzip2 openssl-devel libyaml-devel libffi-devel readline-devel zlib-devel gdbm-devel ncurses-devel"
run "git clone https://github.com/rbenv/ruby-build.git /root/ruby-build"
run "cd /root/ruby-build && git pull && git checkout 86909bfd59f5a6206c560e115694a249d42e4e5b"
run "cd /root/ruby-build && ./install.sh"
run "yum install -y gcc make"
run "CONFIGURE_OPTS='--disable-install-doc' ruby-build 2.4.1 /usr/local"

run "echo #{attributes["s3"]["secret_access_key"]} > /root/secret_access_key"
run "mkdir /root/.ssh && chmod 400 /root/.ssh"
copy "root/.ssh/id_rsa /root/.ssh/id_rsa"
copy "root/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub"
copy "root/s3.yml /root/s3.yml"
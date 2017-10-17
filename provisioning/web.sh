#! /usr/bin/env bash
#
# Installs a simple LAMP stack

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

#mariadb_root_password='7OdFobyak}0vedutNat+'
#wordpress_database='wordpress'
#wordpress_user='wordpress_user'
#wordpress_password='Amt_OtMat7'
#}}}

main() {
  install_packages
  configure_webserver
}

#{{{ Helper functions

install_packages() {

  info "Installing packages"

  yum install -y epel-release
  yum install -y \
    audit \
    bash-completion \
    bash-completion-extras \
    bind-utils \
    git \
    httpd \
    mod_ssl \
    policycoreutils-python \
    php \
    php-mysql \
    pciutils \
    psmisc \
    tree \
    vim-enhanced \
    wordpress

  info "Setting up services, security"

  systemctl start auditd.service
  systemctl enable auditd.service
  systemctl start firewalld.service
  systemctl enable firewalld.service

  setenforce 1
  sed -i "s/^SELINUX=.*$/SELINUX=enforcing/" /etc/selinux/config

  ifdown enp0s8
}

configure_webserver() {
  info "Installing test page"
  cp /vagrant/www/test.php /var/www/html
  cp /vagrant/www/test.php /home/vagrant

  info "Setting port number"
  sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
}

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}
#}}}

main "${@}"


#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
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

mariadb_root_password='7OdFobyak}0vedutNat+'
wordpress_database='wordpress'
wordpress_user='wordpress_user'
wordpress_password='Amt_OtMat7'
#}}}

main() {
  install_packages
  setup_mariadb
}

#{{{ Helper functions

install_packages() {

  info "Installing packages"

  yum install -y epel-release
  yum install -y \
    audit \
    bind-utils \
    git \
    httpd \
    mariadb \
    mariadb-server \
    mod_ssl \
    php \
    php-mysql \
    psmisc \
    tree \
    vim-enhanced \
    wordpress
}

setup_mariadb() {

  info "Set MariaDB root password"

  if mysqladmin -u root status > /dev/null 2>&1; then
    # if the previous command succeeds, the root password was not set
    mysqladmin password "${mariadb_root_password}" > /dev/null 2>&1
    info "ok"
  else
    info "password already set."
  fi

  info "Creating database"

  mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
  CREATE DATABASE IF NOT EXISTS ${wordpress_database};
  GRANT ALL ON ${wordpress_database}.* TO '${wordpress_user}'@'localhost' identified by '${wordpress_password}';
  DELETE FROM user WHERE user='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
  _EOF_

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


#! /usr/bin/env bash
#
# Installs and configures MariaDB

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
  # Ensure vagrant can read logs without sudo
  usermod --append --groups adm vagrant

  install_packages
  start_basic_services
  setup_mariadb

  ensure_db_exists "${wordpress_database}" "${wordpress_user}" "${wordpress_password}"
  initialize_demo_db
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
    mariadb \
    mariadb-server \
    mod_ssl \
    pciutils \
    policycoreutils-python \
    psmisc \
    tree \
    vim-enhanced

}

start_basic_services() {
  info "Starting essential services"
  systemctl start auditd.service
  systemctl restart network.service
  systemctl start firewalld.service
}

setup_mariadb() {
  info "Starting MariaDB"
  systemctl start mariadb.service
  systemctl enable mariadb.service
  firewall-cmd --add-service=mysql
  firewall-cmd --add-service=mysql --permanent

  info "Set MariaDB root password"

  if mysqladmin -u root status > /dev/null 2>&1; then
    # if the previous command succeeds, the root password was not set
    mysqladmin password "${mariadb_root_password}" > /dev/null 2>&1
    info "ok"
  else
    info "password already set."
  fi

  info "Securing database installation"

  mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
DELETE FROM user WHERE user='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
_EOF_

}

ensure_db_exists() {
  local db_name="${1}"
  local db_user="${2}"
  local db_password="${3}"

  info "Creating database ${db_name} and user ${db_user}"

  mysql --user=root --password="${mariadb_root_password}" mysql << _EOF_
CREATE DATABASE IF NOT EXISTS ${db_name};
GRANT ALL ON ${db_name}.* TO '${db_user}'@'%' identified by '${db_password}';
FLUSH PRIVILEGES;
_EOF_
}

initialize_demo_db() {
  local db='demo'
  local usr='demo'
  local passwd='demo'

  ensure_db_exists "${db}" "${usr}" "${passwd}"

  info "Inserting data into database ${db}"

  mysql --user="${usr}" --password="${passwd}" "${db}" << _EOF_
DROP TABLE IF EXISTS demo;
CREATE TABLE demo (
  id int(5) NOT NULL AUTO_INCREMENT,
  name varchar(50) DEFAULT NULL,
  PRIMARY KEY(id)
);
INSERT INTO demo (name) VALUES ("Tux");
INSERT INTO demo (name) VALUES ("Johnny");
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

